from __future__ import print_function

import pyzabbix
import logging
import os
import logging.config
import time
import collections
import util


class ZabbixCollector(object):

    def __init__(self):
        self.log = logging.getLogger(self.__class__.__name__)
        self._config = util.Config()
        self._item_keys = []
        self._period_data = 60
        self._conn = self._config.get_db_connect()
        self._load_config()

    def _load_config(self):
        curr = self._conn.cursor()

        curr.execute('select config_key, config_value from config where config_key like %s', ('zabbix_%',))

        keys = set()
        for (config_key, config_value) in curr:
            if config_key == 'zabbix_item_key':
                keys.add(config_value)
            if config_key == 'zabbix_query_interval':
                self._period_data = int(config_value)

        self._item_keys = list(keys)

        curr.close()

    def collect(self):
        self.log.info('Connecting to database')

        conn = self._conn

        curr = conn.cursor()

        curr.execute('select cbis_pod_id, cbis_pod_name, cbis_zabbix_url, cbis_zabbix_username,'
                     'cbis_zabbix_password, cbis_zabbix_last_sync from cbis_pod where enable=1')

        for (cbis_pod_id, cbis_pod_name, cbis_zabbix_url, cbis_zabbix_username, cbis_zabbix_password,
             cbis_zabbix_last_sync) in curr:
            cbis_zabbix_last_sync = self._collect_pod(cbis_pod_id=cbis_pod_id,
                                                      cbis_pod_name=cbis_pod_name,
                                                      cbis_zabbix_url=cbis_zabbix_url,
                                                      cbis_zabbix_username=cbis_zabbix_username,
                                                      cbis_zabbix_password=cbis_zabbix_password,
                                                      cbis_zabbix_last_sync=cbis_zabbix_last_sync)

            curr.execute('update cbis_pod set cbis_zabbix_last_sync = %s where cbis_pod_id = %s',
                         (cbis_zabbix_last_sync, cbis_pod_id))
            conn.commit()

        curr.close()

    def _collect_pod(self, cbis_pod_id, cbis_pod_name, cbis_zabbix_url, cbis_zabbix_username, cbis_zabbix_password,
                     cbis_zabbix_last_sync):

        self.log.info('connecting to zabbix url : %s' % (cbis_zabbix_url,))

        api = pyzabbix.ZabbixAPI(cbis_zabbix_url)
        api.session.verify = False
        api.login(user=cbis_zabbix_username, password=cbis_zabbix_password)

        hosts = api.host.get(output=['name', 'hostid'], search={'name': 'overcloud-'})

        host_ids = []
        host_data = {}

        output_records = []

        for host in hosts:
            host_id = host['hostid']
            host_ids.append(host_id)
            host_data[host_id] = host

        items = api.item.get(hostids=host_ids,
                             monitored=True,
                             filter={'key_': self._item_keys},
                             output=['name', 'key_', 'value_type', 'hostid', 'units'])

        items_id_from_type = collections.defaultdict(list)
        # items_id_type_0 = []
        # items_id_type_3 = []
        items_data = {}
        for item in items:
            item_id = item['itemid']

            items_id_from_type[item['value_type']].append(item_id)

            # if '0' == item['value_type']:
            #     items_id_type_0.append(item_id)
            # elif '3' == item['value_type']:
            #     items_id_type_3.append(item_id)

            items_data[item_id] = item
            item['hostname'] = host_data[item['hostid']]['name']

        # Possible values:
        # 0 - numeric float;
        # 1 - character;
        # 2 - log;
        # 3 - numeric unsigned;
        # 4 - text.

        now = time.time()
        while cbis_zabbix_last_sync < now:
            history_objects = []
            time_till = int(cbis_zabbix_last_sync) + 60 * self._period_data
            for item_type in items_id_from_type:
                self.log.info('Getting history.get from %s to %s for item_type %s' % (
                    time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(cbis_zabbix_last_sync)),
                    time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time_till)),
                    item_type))

                history_objects.extend(api.history.get(itemids=items_id_from_type[item_type],
                                                       history=item_type,
                                                       time_from=int(cbis_zabbix_last_sync),
                                                       time_till=time_till,
                                                       sortfield=['itemid', 'clock']))

            # aggregate per period_data
            current_item_id = None
            item_values = []

            # add time_till as the sync point of time
            all_clock_timestamp = [time_till]

            for history in history_objects:
                item_id = history['itemid']
                item = items_data[item_id]
                value = history['value']

                all_clock_timestamp.append(float(history['clock']))

                if item_id != current_item_id:
                    if len(item_values) > 0:
                        output_records.extend(
                            self._aggregate_data(items_data[current_item_id], item_values, time_till, cbis_pod_id))
                    current_item_id = item_id
                    item_values = []

                item_values.append(value)

            if len(item_values) > 0:
                output_records.extend(
                    self._aggregate_data(items_data[current_item_id], item_values, time_till, cbis_pod_id))

            # mark last sync time
            if len(all_clock_timestamp) > 0:
                cbis_zabbix_last_sync = max(all_clock_timestamp)

            if len(output_records) > 1000:
                # same object
                self._save_aggregate_data(output_records)
                output_records = []

        if len(output_records) > 0:
            # same object
            self._save_aggregate_data(output_records)
            output_records = []
        return cbis_zabbix_last_sync

    def _save_aggregate_data(self, records):
        conn = self._conn

        curr = conn.cursor()

        curr.executemany(
            'INSERT INTO cbis_zabbix_agg (cbis_pod_id, hostname, item_key, item_value, item_unit, item_agg_type, clock) '
            'VALUES (%(cbis_pod_id)s, %(hostname)s, %(item_key)s, %(item_value)s, %(item_unit)s, %(item_agg_type)s, %(clock)s)',
            records)

        curr.close()

    @staticmethod
    def _aggregate_data(item, history_values, clock, cbis_pod_id):
        output_records = []

        item_value_type = item['value_type']
        if item_value_type in ['0', '3']:
            values = [float(value) for value in history_values]

            max_value = max(values)
            min_value = min(values)
            avg_value = sum(values) / len(values)

            output_records.append({'cbis_pod_id': cbis_pod_id,
                                   'clock': clock,
                                   'hostname': item['hostname'],
                                   'item_key': item['key_'],
                                   'item_value': max_value,
                                   'item_unit': item['units'],
                                   'item_agg_type': 'max'})

            output_records.append({'cbis_pod_id': cbis_pod_id,
                                   'clock': clock,
                                   'hostname': item['hostname'],
                                   'item_key': item['key_'],
                                   'item_value': min_value,
                                   'item_unit': item['units'],
                                   'item_agg_type': 'min'})

            output_records.append({'cbis_pod_id': cbis_pod_id,
                                   'clock': clock,
                                   'hostname': item['hostname'],
                                   'item_key': item['key_'],
                                   'item_value': avg_value,
                                   'item_unit': item['units'],
                                   'item_agg_type': 'avg'})
        else:
            values = [str(value) for value in history_values]

            output_records.append({'cbis_pod_id': cbis_pod_id,
                                   'clock': clock,
                                   'hostname': item['hostname'],
                                   'item_key': item['key_'],
                                   'item_value': values[0],
                                   'item_unit': item['units'],
                                   'item_agg_type': 'str'})

        return output_records


if __name__ == '__main__':
    PATH = os.path.dirname(os.path.abspath(__file__))
    logging.config.fileConfig(os.path.join(PATH, 'logging.ini'))
    client = ZabbixCollector()
    client.collect()
