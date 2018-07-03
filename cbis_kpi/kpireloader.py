from __future__ import print_function
import sys
import os
import logging.config
from datetime import timedelta
import time
import argparse
from datetime import datetime
import util
import pyzabbix
import collections


class ZabbixReloader(object):

    def __init__(self, cbis_pod_name, from_date, to_date):
        self.log = logging.getLogger(self.__class__.__name__)
        self._config = util.Config()
        self._item_keys = []
        self._period_data = 60
        self._conn = None
        self._load_config()
        self._cbis_pod_name = cbis_pod_name
        self._from_date = from_date
        self._to_date = to_date

    def _load_config(self):

        with util.DBConnection().get_connection() as conn:

            curr = conn.cursor()

            curr.execute('select config_key, config_value from config where config_key like %s', ('zabbix_%',))

            keys = set()
            for (config_key, config_value) in curr:
                if config_key == 'zabbix_item_key':
                    keys.add(config_value)
                if config_key == 'zabbix_query_interval':
                    self._period_data = int(config_value)

            self._item_keys = list(keys)

    ### no need to partion old data (all partitions use less than (value), it will fix the last partition)
    # def _partition_util(self, table_name):
    #     from_date = self._from_date
    #     to_date = self._to_date
    #     check_date = from_date.replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)
    #     with util.DBConnection().get_connection() as conn:
    #         curr = conn.cursor()
    #         while check_date < to_date:
    #             try:
    #                 create_partition_sql = 'alter table %s add partition (' \
    #                                        'partition p_%s values less than (%s))' % \
    #                                        (table_name, check_date.strftime('%s'), check_date.strftime('%s'))
    #                 self.log.info('checking partition for %s p_%s' % (table_name, check_date.strftime('%s'),))
    #                 curr.execute(create_partition_sql)
    #                 self.log.info('created partition for %s p_%s' % (table_name, check_date.strftime('%s'),))
    #             except Exception as e:
    #                 self.log.info('partition not found %s p_%s [%s]' % (table_name, check_date.strftime('%s'), e,))
    #                 pass
    #
    #             check_date = check_date + timedelta(days=1)
    #
    #         conn.commit()

    # def partition(self):
    #     self._partition_util('cbis_zabbix_raw')

    def collect(self):

        self.log.info('Connecting to database')

        with util.DBConnection().get_connection() as conn:

            self._conn = conn

            curr = conn.cursor()

            curr.execute('select cbis_pod_id, cbis_pod_name, cbis_zabbix_url, cbis_zabbix_username,'
                         'cbis_zabbix_password from cbis_pod where cbis_pod_name=%s',
                         (self._cbis_pod_name,))

            result_list = curr.fetchall()

            for (cbis_pod_id, cbis_pod_name, cbis_zabbix_url, cbis_zabbix_username, cbis_zabbix_password) in result_list:
                self._collect_pod(cbis_pod_id=cbis_pod_id,
                                  cbis_zabbix_url=cbis_zabbix_url,
                                  cbis_zabbix_username=cbis_zabbix_username,
                                  cbis_zabbix_password=cbis_zabbix_password)

                conn.commit()

    def _collect_pod(self, cbis_pod_id, cbis_zabbix_url, cbis_zabbix_username, cbis_zabbix_password):

        self.log.info('connecting to zabbix url : %s' % (cbis_zabbix_url,))

        api = pyzabbix.ZabbixAPI(cbis_zabbix_url)

        api.session.verify = False
        api.login(user=cbis_zabbix_username, password=cbis_zabbix_password)

        hosts = api.host.get(output=['name', 'hostid'], search={'name': 'overcloud-'})

        host_ids = []
        host_data = {}

        for host in hosts:
            host_id = host['hostid']
            host_ids.append(host_id)
            host_data[host_id] = host

        items = api.item.get(hostids=host_ids,
                             monitored=True,
                             filter={'key_': self._item_keys},
                             output=['name', 'key_', 'value_type', 'hostid', 'units'])

        items_id_from_type = collections.defaultdict(list)

        items_data = {}
        for item in items:
            item_id = item['itemid']

            items_id_from_type[item['value_type']].append(item_id)

            items_data[item_id] = item
            item['hostname'] = host_data[item['hostid']]['name']

        # Possible values:
        # 0 - numeric float;
        # 1 - character;
        # 2 - log;
        # 3 - numeric unsigned;
        # 4 - text.

        sync_time_till = int(self._to_date.strftime('%s'))
        cbis_zabbix_last_sync = int(self._from_date.strftime('%s'))
        has_some_collected = False
        while cbis_zabbix_last_sync < sync_time_till:
            has_some_collected = True
            history_objects = []
            time_till = int(cbis_zabbix_last_sync) + 60 * self._period_data
            for item_type in items_id_from_type:
                self.log.info('Getting history.get from %s to %s for item_type %s' % (
                    time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(cbis_zabbix_last_sync)),
                    time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time_till)),
                    item_type))

                for items_id_by_chunk in util.chunks(items_id_from_type[item_type], 100):
                    for i in range(4):
                        try:
                            history_objects.extend(api.history.get(itemids=items_id_by_chunk,
                                                                   history=item_type,
                                                                   time_from=int(cbis_zabbix_last_sync),
                                                                   time_till=time_till,
                                                                   sortfield=['itemid', 'clock']))
                            break
                        except:
                            self.log.exception('error getting history, retrying for %s' % (i,))


            # raw records
            row_records = []

            for history in history_objects:
                item_id = history['itemid']
                item = items_data[item_id]
                value = history['value']
                clock = history['clock']

                item_value_type = item['value_type']

                row_records.append({'cbis_pod_id': cbis_pod_id,
                                    'hostname': item['hostname'],
                                    'item_key': item['key_'],
                                    'item_value': value,
                                    'item_unit': item['units'],
                                    'clock': clock})

                if len(row_records) > 10000:
                    self._save_raw(row_records)
                    row_records = []

            if len(row_records) > 0:
                self._save_raw(row_records)
                row_records = []

        if not has_some_collected:
            self.log.info('Nothing to collect since current period not full period yet. ')

    def _save_raw(self, records):
        conn = self._conn

        curr = conn.cursor()

        curr.executemany(
            'INSERT INTO cbis_zabbix_raw (cbis_pod_id, hostname, item_key, item_value, item_unit, clock) '
            'VALUES (%(cbis_pod_id)s, %(hostname)s, %(item_key)s, %(item_value)s, %(item_unit)s, %(clock)s)',
            records)


def main(args=sys.argv[1:]):
    PATH = os.path.dirname(os.path.abspath(__file__))
    logging.config.fileConfig(os.path.join(PATH, 'logging.ini'))

    log = logging.getLogger(__name__)

    arg_parser = build_parser()
    args = arg_parser.parse_args(args)

    from_date = args.from_date

    to_date = args.to_date

    cbis_pod_name = args.cbis_pod_name

    reloader = ZabbixReloader(to_date=to_date, from_date=from_date, cbis_pod_name=cbis_pod_name)
    # reloader.partition()
    reloader.collect()


def build_parser():
    """
    Builds the argparser object
    :return: Configured argparse.ArgumentParser object
    """
    def valid_date(s):
        try:
            return datetime.strptime(s, "%d-%m-%Y %H:%M")
        except ValueError:
            msg = "Not a valid date: '{0}'.".format(s)
            raise argparse.ArgumentTypeError(msg)

    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description='Reload KPI from Zabbix ')

    parser.add_argument('--from_date',
                        help='From date format DD-MM-YYYY HH:MM',
                        required=True,
                        type=valid_date)

    parser.add_argument('--to_date',
                        help='To date format DD-MM-YYYY HH:MM',
                        required=True,
                        type=valid_date)

    parser.add_argument('--cbis_pod_name',
                        required=True,
                        help='cbis_pod_name from database')

    return parser


if __name__ == "__main__":
    exit(main(args=sys.argv[1:]))
