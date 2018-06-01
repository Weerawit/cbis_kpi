from __future__ import print_function

import pyzabbix
import logging
import os
import logging.config
import time
import collections
from datetime import timedelta, datetime
import util

def chunks(l, n):
    """Yield successive n-sized chunks from l."""
    for i in xrange(0, len(l), n):
        yield l[i:i + n]

class ZabbixCollector(object):

    def __init__(self):
        self.log = logging.getLogger(self.__class__.__name__)
        self._config = util.Config()
        self._item_keys = []
        self._period_data = 60
        self._conn = None
        self._load_config()

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

            curr.close()

    def _partition_util(self, table_name, number_of_days=14):
        tomorrow = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)
        last_days = tomorrow - timedelta(days=number_of_days)
        with util.DBConnection().get_connection() as conn:
            curr = conn.cursor()

            try:
                create_partition_sql = 'alter table %s add partition (' \
                                       'partition p_%s values less than (%s))' % \
                                       (table_name, tomorrow.strftime('%s'), tomorrow.strftime('%s'))
                self.log.info('checking partition for %s p_%s' % (table_name, tomorrow.strftime('%s'),))
                curr.execute(create_partition_sql)
                self.log.info('created partition for %s p_%s' % (table_name, tomorrow.strftime('%s'),))
            except:
                self.log.info('partition not found %s p_%s' % (table_name, tomorrow.strftime('%s'),))
                pass

            try:
                drop_partition_sql = 'alter table %s drop partition p_%s' % (table_name, last_days.strftime('%s'),)
                self.log.info('checking partition to delete for %s p_%s' % (table_name, last_days.strftime('%s'),))
                curr.execute(drop_partition_sql)
                self.log.info('dropped partition for %s p_%s' % (table_name, last_days.strftime('%s'),))
            except:
                self.log.info('partition not found %s p_%s' % (table_name, last_days.strftime('%s'),))
                pass
            conn.commit()

            curr.close()

    def partition(self):
        self._partition_util('cbis_zabbix_raw', 14)
        self._partition_util('cbis_zabbix_hour', 90)
        self._partition_util('cbis_zabbix_day', 365)

    def collect(self):
        self.log.info('Connecting to database')

        with util.DBConnection().get_connection() as conn:

            self._conn = conn

            curr = conn.cursor()

            curr.execute('select cbis_pod_id, cbis_pod_name, cbis_zabbix_url, cbis_zabbix_username,'
                         'cbis_zabbix_password, cbis_zabbix_last_sync from cbis_pod where enable=1')

            for (cbis_pod_id, cbis_pod_name, cbis_zabbix_url, cbis_zabbix_username, cbis_zabbix_password,
                 cbis_zabbix_last_sync) in curr:
                cbis_zabbix_last_sync = self._collect_pod(cbis_pod_id=cbis_pod_id,
                                                          cbis_zabbix_url=cbis_zabbix_url,
                                                          cbis_zabbix_username=cbis_zabbix_username,
                                                          cbis_zabbix_password=cbis_zabbix_password,
                                                          cbis_zabbix_last_sync=cbis_zabbix_last_sync)

                curr.execute('update cbis_pod set cbis_zabbix_last_sync = %s where cbis_pod_id = %s',
                             (cbis_zabbix_last_sync, cbis_pod_id))
                conn.commit()

            curr.close()

    def _collect_pod(self, cbis_pod_id, cbis_zabbix_url, cbis_zabbix_username, cbis_zabbix_password,
                     cbis_zabbix_last_sync, sync_time_till=time.time()):

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

        time_till = int(cbis_zabbix_last_sync) + 60 * self._period_data
        has_some_collected = False
        while cbis_zabbix_last_sync < sync_time_till and time_till < sync_time_till:
            has_some_collected = True
            history_objects = []
            time_till = int(cbis_zabbix_last_sync) + 60 * self._period_data
            for item_type in items_id_from_type:
                self.log.info('Getting history.get from %s to %s for item_type %s' % (
                    time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(cbis_zabbix_last_sync)),
                    time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time_till)),
                    item_type))

                for items_id_by_chunk in chunks(items_id_from_type[item_type], 100):
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

            # add time_till as the sync point of time
            all_clock_timestamp = [time_till]

            for history in history_objects:
                item_id = history['itemid']
                item = items_data[item_id]
                value = history['value']
                clock = history['clock']

                all_clock_timestamp.append(float(history['clock']))

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

            # mark last sync time
            if len(all_clock_timestamp) > 0:
                cbis_zabbix_last_sync = max(all_clock_timestamp)

        if not has_some_collected:
            self.log.info('Nothing to collect since current period not full period yet. ')

        return cbis_zabbix_last_sync

    def _save_raw(self, records):
        conn = self._conn

        curr = conn.cursor()

        curr.executemany(
            'INSERT INTO cbis_zabbix_raw (cbis_pod_id, hostname, item_key, item_value, item_unit, clock) '
            'VALUES (%(cbis_pod_id)s, %(hostname)s, %(item_key)s, %(item_value)s, %(item_unit)s, %(clock)s)',
            records)

        curr.close()

    def aggregate_hourly(self, now=time.time()):
        last_hour = datetime.fromtimestamp(now).replace(minute=0, second=0, microsecond=0) - timedelta(hours=1)
        current_hour = last_hour + timedelta(hours=1)

        sql = 'select cbis_pod_id, hostname, item_key, item_unit, max(item_value), min(item_value), avg(item_value) from cbis_zabbix_raw ' \
              'where clock >= %(from_date)s and clock < %(to_date)s ' \
              'group by cbis_pod_id, hostname, item_key, item_unit'

        params = {'from_date': last_hour.strftime('%s'),
                  'to_date': current_hour.strftime('%s')}

        self.log.info('Aggregate Hourly from %s to %s' %
                      (last_hour.strftime('%Y-%m-%d %H:%M:%S'), current_hour.strftime('%Y-%m-%d %H:%M:%S')))

        with util.DBConnection().get_connection() as conn:

            curr = conn.cursor()

            curr.execute(sql, params)

            hourly_records = []
            for (cbis_pod_id, hostname, item_key, item_unit, max_value, min_value, avg_value) in curr:
                hourly_records.append({'cbis_pod_id':cbis_pod_id,
                                       'hostname': hostname,
                                       'item_key': item_key,
                                       'item_unit': item_unit,
                                       'max_value': max_value,
                                       'min_value': min_value,
                                       'avg_value': avg_value,
                                       'clock': params['to_date']})

            #delete data
            delete_sql = 'delete from cbis_zabbix_hour where clock = %(clock)s'
            curr.execute(delete_sql, {'clock': params['to_date']})

            insert_sql = 'insert into cbis_zabbix_hour (cbis_pod_id, hostname, item_key, item_unit, max_value, min_value, avg_value, clock) ' \
                         'values (%(cbis_pod_id)s, %(hostname)s, %(item_key)s, %(item_unit)s, %(max_value)s, %(min_value)s, %(avg_value)s, %(clock)s)'

            curr.executemany(insert_sql, hourly_records)

            curr.close()

            conn.commit()

    def aggregate_daily(self, now=time.time()):
        yesterday = datetime.fromtimestamp(now).replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(days=1)
        today = yesterday + timedelta(days=1)

        sql = 'select cbis_pod_id, hostname, item_key, item_unit, max(max_value), min(min_value), avg(avg_value) from cbis_zabbix_hour ' \
              'where clock >= %(from_date)s and clock < %(to_date)s ' \
              'group by cbis_pod_id, hostname, item_key, item_unit'

        params = {'from_date': yesterday.strftime('%s'),
                  'to_date': today.strftime('%s')}

        self.log.info('Aggregate Daily from %s to %s' %
                      (yesterday.strftime('%Y-%m-%d %H:%M:%S'),today.strftime('%Y-%m-%d %H:%M:%S')))

        with util.DBConnection().get_connection() as conn:

            curr = conn.cursor()

            curr.execute(sql, params)

            daily_records = []
            for (cbis_pod_id, hostname, item_key, item_unit, max_value, min_value, avg_value) in curr:
                daily_records.append({'cbis_pod_id':cbis_pod_id,
                                      'hostname': hostname,
                                      'item_key': item_key,
                                      'item_unit': item_unit,
                                      'max_value': max_value,
                                      'min_value': min_value,
                                      'avg_value': avg_value,
                                      'clock': params['to_date']})

            #delete data
            delete_sql = 'delete from cbis_zabbix_day where clock = %(clock)s'
            curr.execute(delete_sql, {'clock': params['to_date']})

            insert_sql = 'insert into cbis_zabbix_day (cbis_pod_id, hostname, item_key, item_unit, max_value, min_value, avg_value, clock) ' \
                         'values (%(cbis_pod_id)s, %(hostname)s, %(item_key)s, %(item_unit)s, %(max_value)s, %(min_value)s, %(avg_value)s, %(clock)s)'

            curr.executemany(insert_sql, daily_records)

            curr.close()

            conn.commit()

    # @staticmethod
    # def _aggregate_data(item, history_values, clock, cbis_pod_id):
    #     output_records = []
    #
    #     item_value_type = item['value_type']
    #     if item_value_type in ['0', '3']:
    #         values = [float(value) for value in history_values]
    #
    #         max_value = max(values)
    #         min_value = min(values)
    #         avg_value = sum(values) / len(values)
    #
    #         output_records.append({'cbis_pod_id': cbis_pod_id,
    #                                'clock': clock,
    #                                'hostname': item['hostname'],
    #                                'item_key': item['key_'],
    #                                'item_value': max_value,
    #                                'item_unit': item['units'],
    #                                'item_type': 'max'})
    #
    #         output_records.append({'cbis_pod_id': cbis_pod_id,
    #                                'clock': clock,
    #                                'hostname': item['hostname'],
    #                                'item_key': item['key_'],
    #                                'item_value': min_value,
    #                                'item_unit': item['units'],
    #                                'item_type': 'min'})
    #
    #         output_records.append({'cbis_pod_id': cbis_pod_id,
    #                                'clock': clock,
    #                                'hostname': item['hostname'],
    #                                'item_key': item['key_'],
    #                                'item_value': avg_value,
    #                                'item_unit': item['units'],
    #                                'item_type': 'avg'})
    #     else:
    #         values = [str(value) for value in history_values]
    #
    #         output_records.append({'cbis_pod_id': cbis_pod_id,
    #                                'clock': clock,
    #                                'hostname': item['hostname'],
    #                                'item_key': item['key_'],
    #                                'item_value': values[0],
    #                                'item_unit': item['units'],
    #                                'item_type': 'str'})
    #
    #     return output_records


if __name__ == '__main__':
    PATH = os.path.dirname(os.path.abspath(__file__))
    logging.config.fileConfig(os.path.join(PATH, 'logging.ini'))
    client = ZabbixCollector()
    client.partition()
    # client.aggregate_daily(now=float((datetime.now() + timedelta(days=1)).strftime('%s')))
