from __future__ import print_function

import collections
import logging
import logging.config
import os
import time
import xml.etree.ElementTree as ET
from datetime import timedelta, datetime
import re
import pyzabbix
import json
import threading
import gzip
import shutil
import util


def partition_util(table_name, number_of_days=14):
    log = logging.getLogger('partition_util')
    tomorrow = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)
    last_days = tomorrow - timedelta(days=number_of_days)
    with util.DBConnection().get_connection() as conn:
        curr = conn.cursor()

        curr.execute('select config_value from config where config_key=\'database_export_location\'')

        database_export_location = str(curr.fetchall()[0][0])

        create_partition_name = 'p_%s' % (tomorrow.strftime('%s'),)

        query_partition_sql = 'explain partitions select * from %s' % (table_name,)
        curr.execute(query_partition_sql)
        partition_list = curr.fetchone()[3]
        found_created_partition = False
        for partition_name in partition_list.split(','):
            if 'p_0' in partition_name:
                continue
            if create_partition_name in partition_name:
                found_created_partition = True
            partition_name = partition_name.replace('p_', '')
            partition_time = datetime.fromtimestamp(float(partition_name))

            if partition_time < last_days:
                try:
                    yesterday_for_partition_time = partition_time - timedelta(days=1)

                    database_export_file = "%s/%s_%s.csv" % (database_export_location, table_name, partition_time.strftime('%Y%m%d'))

                    database_export_file_gzip = "%s/%s_%s.gz" % (database_export_location, table_name, partition_time.strftime('%Y%m%d'))

                    export_sql = 'select * from %s where clock >= %s and clock < %s ' \
                                 'into outfile \'%s\' ' \
                                 'fields terminated by \',\' ' \
                                 'enclosed by \'"\' ' \
                                 'lines terminated by \'\\n\'' % (table_name, yesterday_for_partition_time.strftime('%s'), partition_time.strftime('%s'), database_export_file)

                    curr.execute(export_sql)

                    with open(database_export_file, 'rb') as f_in, gzip.open(database_export_file_gzip, 'wb') as f_out:
                        shutil.copyfileobj(f_in, f_out)

                    drop_partition_sql = 'alter table %s drop partition p_%s' % (
                        table_name, partition_time.strftime('%s'),)

                    curr.execute(drop_partition_sql)
                    log.info('dropped partition for %s p_%s' % (table_name, partition_time.strftime('%s'),))
                except Exception as e:
                    log.info('partition not found %s p_%s [%s]' % (table_name, partition_time.strftime('%s'), e))
                pass

        if not found_created_partition:
            try:
                create_partition_sql = 'alter table %s add partition (' \
                                       'partition p_%s values less than (%s))' % \
                                       (table_name, tomorrow.strftime('%s'), tomorrow.strftime('%s'))
                curr.execute(create_partition_sql)
                log.info('created partition for %s p_%s' % (table_name, tomorrow.strftime('%s'),))
            except Exception as e:
                log.info('partition has been created %s p_%s [%s]' % (table_name, tomorrow.strftime('%s'), e))
                pass

        conn.commit()


class VirshThread(threading.Thread):

    def __init__(self, cbis_pod_id, cbis_pod_name, cbis_undercloud_addr, cbis_undercloud_username,
                 cbis_undercloud_last_sync):
        super(VirshThread, self).__init__()
        self.log = logging.getLogger(self.__class__.__name__)
        self.cbis_pod_id = cbis_pod_id
        self.cbis_pod_name = cbis_pod_name
        self.cbis_undercloud_addr = cbis_undercloud_addr
        self.cbis_undercloud_username = cbis_undercloud_username
        self.cbis_undercloud_last_sync = cbis_undercloud_last_sync

    def run(self):
        with util.DBConnection().get_connection() as conn:
            try:
                conn.start_transaction(isolation_level='READ COMMITTED')
                cbis_undercloud_current_sync = time.time()
                kwargs = {'cbis_undercloud_last_sync': self.cbis_undercloud_last_sync,
                          'cbis_pod_id': self.cbis_pod_id,
                          'cbis_undercloud_current_sync': cbis_undercloud_current_sync,
                          'test_flag': False,
                          'conn': conn}

                executor = util.SshExecutor(self.cbis_undercloud_addr, self.cbis_undercloud_username, **kwargs)

                executor.run('compute-*',
                             'sudo ip link; sudo virsh list | head -n -1 | tail -n +3 | awk \"{ system(\\\"sudo virsh dumpxml \\\" \$2)}\"',
                             callback=self._callback_dumpxml)

                executor.run('compute-*',
                             'sudo virsh list | head -n -1 | tail -n +3 | awk \"{ system(\\\"sudo virsh domstats \\\" \$2)}\"',
                             callback=self._callback_stat)

                executor.run('compute-*',
                             'sudo virsh list | head -n -1 | tail -n +3 | awk \"{ print \\\"Domain: \\\" \$2; system(\\\"sudo virsh dommemstat \\\" \$2)}\"',
                             callback=self._callback_memstat)

                executor.run('undercloud',
                             'source /home/stack/overcloudrc;openstack project list -f json;nova list --all --fields host,name,instance_name,tenant_id',
                             callback=self._callback_novalist)

                curr = conn.cursor()

                curr.execute('update cbis_pod set cbis_undercloud_last_sync = %s where cbis_pod_id = %s',
                         (cbis_undercloud_current_sync, self.cbis_pod_id))

                conn.commit()
            except Exception as e:
                self.log.error("VirshThread error: {0}".format(e))

    def _callback_novalist(self, hostname, line_each_node, **kwargs):
        cbis_pod_id = kwargs.get('cbis_pod_id')

        records = []

        lines = line_each_node.splitlines()
        project_list = json.loads(lines[0])
        i = 1
        while i < len(lines):
            line = lines[i]
            i += 1
            if 'overcloud-compute-' in line:
                try:
                    values = line.split('|')
                    domain_name = values[4].strip()
                    tenent_id = values[5].strip()
                    project_name = ''
                    for project in project_list:
                        if tenent_id in project.get('ID'):
                            project_name = project.get('Name')

                    records.append({'cbis_pod_id': cbis_pod_id,
                                    'project_name': project_name,
                                    'domain_name': domain_name})
                except IndexError:
                    pass

        conn = kwargs.get('conn')

        curr = conn.cursor()

        sql = 'update cbis_virsh_list set project_name = %(project_name)s where cbis_pod_id = %(cbis_pod_id)s and domain_name = %(domain_name)s'

        curr.executemany(sql, records)

    def _callback_dumpxml(self, hostname, line_each_node, **kwargs):
        cbis_pod_id = kwargs.get('cbis_pod_id')
        virsh_list_records = []
        domain_xml = ""
        found_domain = False
        iplink_re = re.compile('^\d*:')
        iplink_data = collections.defaultdict(list)
        kwargs['iplink'] = iplink_data
        i = 0
        lines = line_each_node.splitlines()
        while i < len(lines):
            line = lines[i]
            i += 1
            if not line:
                continue
            if "<domain type='kvm'" in line:
                found_domain = True
                domain_xml += line
            elif "</domain>" in line:
                domain_xml += line
                found_domain = False
                virsh_list_records.append(self._parse_xml(hostname, domain_xml, **kwargs))
                domain_xml = ""
            elif found_domain:
                if not line.isspace():
                    domain_xml += line
            elif iplink_re.match(line):
                if_name = line.split(':')[1].strip()
                i += 1
                line = lines[i]
                try:
                    while not iplink_re.match(line) and "<domain type='kvm'" not in line:
                        iplink_data[if_name].append(line)
                        i += 1
                        line = lines[i]
                except IndexError:
                    pass

        with util.DBConnection().get_connection() as conn:
            conn.start_transaction(isolation_level='READ COMMITTED')

            curr = conn.cursor()

            delete_sql = 'delete from cbis_virsh_list where cbis_pod_id = %(cbis_pod_id)s and hostname = %(hostname)s'

            curr.execute(delete_sql, {'cbis_pod_id': cbis_pod_id,
                                      'hostname': hostname})

            delete_sql = 'delete from cbis_virsh_meta where cbis_pod_id = %(cbis_pod_id)s and hostname = %(hostname)s'

            curr.execute(delete_sql, {'cbis_pod_id': cbis_pod_id,
                                      'hostname': hostname})

            #metadata for nic
            meta_records = []
            for virsh_list_record in virsh_list_records:
                for nic in virsh_list_record.pop('physical_nic'):
                    meta_records.append({'cbis_pod_id': virsh_list_record.get('cbis_pod_id'),
                                         'hostname': virsh_list_record.get('hostname'),
                                         'domain_name': virsh_list_record.get('domain_name'),
                                         'meta_key': 'nic',
                                         'meta_value': nic})

            insert_sql = 'insert into cbis_virsh_list (cbis_pod_id, hostname, domain_name, vm_name, vm_flavor, vm_vcpu, vm_memory, vm_numa) ' \
                         'values (%(cbis_pod_id)s, %(hostname)s, %(domain_name)s, %(vm_name)s, %(vm_flavor)s, %(vm_vcpu)s, %(vm_memory)s, %(vm_numa)s)'
            curr.executemany(insert_sql, virsh_list_records)

            insert_sql = 'insert into cbis_virsh_meta (cbis_pod_id, hostname, domain_name, meta_key, meta_value) ' \
                         'values (%(cbis_pod_id)s, %(hostname)s, %(domain_name)s, %(meta_key)s, %(meta_value)s)'
            curr.executemany(insert_sql, meta_records)

            conn.commit()

    def _parse_xml(self, hostname, domain_xml, **kwargs):
        cbis_pod_id = kwargs.get('cbis_pod_id')
        iplink_data = kwargs.get('iplink')
        ns = {'nova': 'http://openstack.org/xmlns/libvirt/nova/1.0'}
        root = ET.fromstring(domain_xml)

        name = root.find(".//nova:name", ns).text
        flavor = root.find(".//nova:flavor", ns).attrib['name']
        memory = root.find(".//nova:memory", ns).text
        vcpu = root.find(".//nova:vcpus", ns).text

        domain_name = root.find('.//name').text

        cpupin = ""
        for cpupinroot in root.findall(".//vcpupin"):
            cpupin += "%s-%s\n" % (cpupinroot.attrib['vcpu'], cpupinroot.attrib['cpuset'])

        numa = "0"
        try:
            numa = root.find(".//memnode").attrib['nodeset']
        except AttributeError:
            numa = "none"

        disk_size = ""
        has_writeback = True
        for diskroot in root.findall(".//disk"):
            rbd_disk = diskroot.find(".//source").attrib['name']
            target_disk = diskroot.find(".//target").attrib['dev']
            writeback = diskroot.find(".//driver").attrib['cache']

            if "writeback" != writeback:
                has_writeback = False

            size = "unknown"
            disk_size += "%s [%s] (%s) = %s\n" % (target_disk, writeback, size, rbd_disk)

        is_sriov = False
        physical_card = []
        for interface_root in root.findall(".//interface"):
            if "hostdev" == interface_root.attrib['type']:
                is_sriov = True
                mac = interface_root.find('.//mac').attrib['address']

                for key, values in list(iplink_data.items()):
                    for value in values:
                        if mac in value:
                            physical_card.append(key)
            else:
                target_dev = interface_root.find('.//target').attrib['dev']
                physical_card.append(target_dev)

        return {'cbis_pod_id': cbis_pod_id,
                'hostname': hostname,
                'domain_name': domain_name,
                'vm_name': name,
                'vm_flavor': flavor,
                'vm_vcpu': vcpu,
                'vm_memory': memory,
                'vm_numa': numa,
                'cpupin': cpupin,
                'disk_size': disk_size,
                'is_sriov': is_sriov,
                'has_writeback': has_writeback,
                'physical_nic': physical_card}

    def _callback_stat(self, hostname, line_each_node, **kwargs):
        domain_name = None
        cbis_undercloud_last_sync = kwargs.get('cbis_undercloud_last_sync')
        cbis_undercloud_current_sync = kwargs.get('cbis_undercloud_current_sync')
        clock_delta = long(cbis_undercloud_current_sync) - long(cbis_undercloud_last_sync)
        cbis_pod_id = kwargs.get('cbis_pod_id')

        data_dict = collections.defaultdict(dict)

        for line in line_each_node.splitlines():
            if not line:
                continue
            if 'Domain:' in line:
                domain_name = line.split(':')[1].strip().replace('\'', '')
            else:
                line = line.strip()
                key, value = line.split('=')
                data_dict[domain_name][key] = value

        # find delta from database
        params = []

        # skip on empty vm on this compute
        if len(data_dict.keys()) == 0:
            return

        sql = 'select domain_name, item_key, item_value from cbis_virsh_stat_raw ' \
              'where domain_name in (%s)' % (','.join(['%s'] * len(data_dict.keys())),)

        sql += ' and cbis_pod_id = %s and clock = %s '

        params.extend(data_dict.keys())
        params.append(cbis_pod_id)
        params.append(cbis_undercloud_last_sync)

        conn = kwargs.get('conn')

        curr = conn.cursor()

        curr.execute(sql, params)

        last_data_dict = collections.defaultdict(dict)
        for (domain_name, item_key, item_value) in curr:
            last_data_dict[domain_name][item_key] = item_value


        # calculate for delta
        cbis_virsh_stat_raw_values = []
        for domain_name, items in data_dict.iteritems():
            for item_key, item_value in items.iteritems():
                if '.count' in item_key or '.name' in item_key or '.state' in item_key or '.reason' in item_key or 'vcpu.current' in item_key or 'vcpu.maximum' in item_key:
                    # .count
                    # .name
                    # .state
                    # .reason
                    # vcpu.current
                    # vcpu.maximum
                    cbis_virsh_stat_raw_values.append({'cbis_pod_id': cbis_pod_id,
                                                       'domain_name': domain_name,
                                                       'item_key': item_key,
                                                       'item_value': item_value,
                                                       'item_delta': item_value,
                                                       'clock': cbis_undercloud_current_sync,
                                                       'clock_delta': clock_delta
                                                      })

                else:
                    previous_value = item_value
                    try:
                        previous_value = last_data_dict[domain_name][item_key]
                    except KeyError:
                        pass

                    delta_value = long(item_value) - long(previous_value)
                    cbis_virsh_stat_raw_values.append({'cbis_pod_id': cbis_pod_id,
                                                       'domain_name': domain_name,
                                                       'item_key': item_key,
                                                       'item_value': item_value,
                                                       'item_delta': delta_value,
                                                       'clock': cbis_undercloud_current_sync,
                                                       'clock_delta': clock_delta
                                                      })

        insert_sql = 'insert into cbis_virsh_stat_raw (cbis_pod_id, domain_name, item_key, item_value, item_delta, clock, clock_delta) ' \
                     'values (%(cbis_pod_id)s, %(domain_name)s, %(item_key)s, %(item_value)s, %(item_delta)s, %(clock)s, %(clock_delta)s)'
        curr.executemany(insert_sql, cbis_virsh_stat_raw_values)

    def _callback_memstat(self, hostname, line_each_node, **kwargs):
        domain_name = None
        cbis_undercloud_last_sync = kwargs.get('cbis_undercloud_last_sync')
        cbis_undercloud_current_sync = kwargs.get('cbis_undercloud_current_sync')
        clock_delta = long(cbis_undercloud_current_sync) - long(cbis_undercloud_last_sync)
        cbis_pod_id = kwargs.get('cbis_pod_id')

        data_dict = collections.defaultdict(dict)

        for line in line_each_node.splitlines():
            if not line:
                continue
            if 'Domain:' in line:
                domain_name = line.split(':')[1].strip()
            else:
                line = line.strip()
                key, value = line.split(' ')
                data_dict[domain_name]['memory.{0}'.format(key)] = value

        # find delta from database
        params = []

        # skip on empty vm on this compute
        if len(data_dict.keys()) == 0:
            return

        sql = 'select domain_name, item_key, item_value from cbis_virsh_stat_raw ' \
              'where domain_name in (%s)' % (','.join(['%s'] * len(data_dict.keys())),)

        sql += ' and cbis_pod_id = %s and clock = %s '

        params.extend(data_dict.keys())
        params.append(cbis_pod_id)
        params.append(cbis_undercloud_last_sync)

        conn = kwargs.get('conn')

        curr = conn.cursor()

        curr.execute(sql, params)

        last_data_dict = collections.defaultdict(dict)
        for (domain_name, item_key, item_value) in curr:
            last_data_dict[domain_name][item_key] = item_value


        # calculate for delta
        cbis_virsh_stat_raw_values = []
        for domain_name, items in data_dict.iteritems():
            for item_key, item_value in items.iteritems():
                previous_value = item_value
                try:
                    previous_value = last_data_dict[domain_name][item_key]
                except KeyError:
                    pass

                delta_value = long(item_value) - long(previous_value)
                cbis_virsh_stat_raw_values.append({'cbis_pod_id': cbis_pod_id,
                                                   'domain_name': domain_name,
                                                   'item_key': item_key,
                                                   'item_value': item_value,
                                                   'item_delta': delta_value,
                                                   'clock': cbis_undercloud_current_sync,
                                                   'clock_delta': clock_delta
                                                  })

        insert_sql = 'insert into cbis_virsh_stat_raw (cbis_pod_id, domain_name, item_key, item_value, item_delta, clock, clock_delta) ' \
                     'values (%(cbis_pod_id)s, %(domain_name)s, %(item_key)s, %(item_value)s, %(item_delta)s, %(clock)s, %(clock_delta)s)'
        curr.executemany(insert_sql, cbis_virsh_stat_raw_values)


class VirshCollector(object):

    def __init__(self):
        self.log = logging.getLogger(self.__class__.__name__)
        self._config = util.Config()
        self._load_config()
        self._conn = None

    def _load_config(self):
        pass

    def partition(self):
        partition_util('cbis_virsh_stat_raw', 90)
        partition_util('cbis_virsh_stat_hour', 365)
        partition_util('cbis_virsh_stat_day', 365)

    def collect(self):
        self.log.info('Connecting to database')

        with util.DBConnection().get_connection() as conn:

            self._conn = conn

            curr = conn.cursor()

            curr.execute('select cbis_pod_id, cbis_pod_name, cbis_undercloud_addr, cbis_undercloud_username,'
                         'cbis_undercloud_last_sync from cbis_pod where enable=1')
            result_list = curr.fetchall()

        all_thread = []

        for (cbis_pod_id, cbis_pod_name, cbis_undercloud_addr, cbis_undercloud_username,
             cbis_undercloud_last_sync) in result_list:
            thread = VirshThread(cbis_pod_id=cbis_pod_id,
                                 cbis_pod_name=cbis_pod_name,
                                 cbis_undercloud_addr=cbis_undercloud_addr,
                                 cbis_undercloud_username=cbis_undercloud_username,
                                 cbis_undercloud_last_sync=cbis_undercloud_last_sync)
            all_thread.append(thread)

        for t in all_thread:
            t.start()
        for t in all_thread:
            t.join()

    def aggregate_hourly(self, now=time.time()):
        last_hour = datetime.fromtimestamp(now).replace(minute=0, second=0, microsecond=0) - timedelta(hours=1)
        current_hour = last_hour + timedelta(hours=1)

        sql = 'select cbis_pod_id, domain_name, item_key, max(item_delta), min(item_delta), avg(item_delta) from cbis_virsh_stat_raw ' \
              'where clock >= %(from_date)s and clock < %(to_date)s ' \
              'group by cbis_pod_id, domain_name, item_key'

        params = {'from_date': last_hour.strftime('%s'),
                  'to_date': current_hour.strftime('%s')}

        self.log.info('Aggregate Hourly from %s to %s' %
                      (last_hour.strftime('%Y-%m-%d %H:%M:%S'), current_hour.strftime('%Y-%m-%d %H:%M:%S')))

        with util.DBConnection().get_connection() as conn:
            conn.start_transaction(isolation_level='READ COMMITTED')

            curr = conn.cursor()

            curr.execute(sql, params)

            hourly_records = []
            for (cbis_pod_id, domain_name, item_key, max_value, min_value, avg_value) in curr:
                hourly_records.append({'cbis_pod_id':cbis_pod_id,
                                       'domain_name': domain_name,
                                       'item_key': item_key,
                                       'max_value': max_value,
                                       'min_value': min_value,
                                       'avg_value': avg_value,
                                       'clock': params['to_date']})

            #delete data
            delete_sql = 'delete from cbis_virsh_stat_hour where clock = %(clock)s'
            curr.execute(delete_sql, {'clock': params['to_date']})

            insert_sql = 'insert into cbis_virsh_stat_hour (cbis_pod_id, domain_name, item_key, max_value, min_value, avg_value, clock) ' \
                         'values (%(cbis_pod_id)s, %(domain_name)s, %(item_key)s, %(max_value)s, %(min_value)s, %(avg_value)s, %(clock)s)'

            for records in util.chunks(hourly_records, 10000):

                curr.executemany(insert_sql, records)

            conn.commit()

    def aggregate_daily(self, now=time.time()):
        yesterday = datetime.fromtimestamp(now).replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(days=1)
        today = yesterday + timedelta(days=1)

        sql = 'select cbis_pod_id, domain_name, item_key, max(max_value), min(min_value), avg(avg_value) from cbis_virsh_stat_hour ' \
              'where clock >= %(from_date)s and clock < %(to_date)s ' \
              'group by cbis_pod_id, domain_name, item_key'

        params = {'from_date': yesterday.strftime('%s'),
                  'to_date': today.strftime('%s')}

        self.log.info('Aggregate Daily from %s to %s' %
                      (yesterday.strftime('%Y-%m-%d %H:%M:%S'),today.strftime('%Y-%m-%d %H:%M:%S')))

        with util.DBConnection().get_connection() as conn:
            conn.start_transaction(isolation_level='READ COMMITTED')
            curr = conn.cursor()

            curr.execute(sql, params)

            daily_records = []
            for (cbis_pod_id, domain_name, item_key, max_value, min_value, avg_value) in curr:
                daily_records.append({'cbis_pod_id':cbis_pod_id,
                                       'domain_name': domain_name,
                                       'item_key': item_key,
                                       'max_value': max_value,
                                       'min_value': min_value,
                                       'avg_value': avg_value,
                                       'clock': params['to_date']})

            #delete data
            delete_sql = 'delete from cbis_virsh_stat_day where clock = %(clock)s'
            curr.execute(delete_sql, {'clock': params['to_date']})

            insert_sql = 'insert into cbis_virsh_stat_day (cbis_pod_id, domain_name, item_key, max_value, min_value, avg_value, clock) ' \
                         'values (%(cbis_pod_id)s, %(domain_name)s, %(item_key)s, %(max_value)s, %(min_value)s, %(avg_value)s, %(clock)s)'

            for records in util.chunks(daily_records, 10000):

                curr.executemany(insert_sql, records)

            conn.commit()


class ZabbixThread(threading.Thread):

    def __init__(self, cbis_pod_id, cbis_pod_name, cbis_zabbix_url, cbis_zabbix_username, cbis_zabbix_password,
             cbis_zabbix_last_sync, item_keys, period_data):
        super(ZabbixThread, self).__init__()
        self.log = logging.getLogger(self.__class__.__name__)
        self.cbis_pod_id = cbis_pod_id
        self.cbis_pod_name = cbis_pod_name
        self.cbis_zabbix_url = cbis_zabbix_url
        self.cbis_zabbix_username = cbis_zabbix_username
        self.cbis_zabbix_password =cbis_zabbix_password
        self.cbis_zabbix_last_sync = cbis_zabbix_last_sync
        self.item_keys = item_keys
        self.period_data = period_data

    def run(self):
        with util.DBConnection().get_connection() as conn:
            try:
                conn.start_transaction(isolation_level='READ COMMITTED')
                cbis_zabbix_last_sync = self._collect_pod(conn)

                # commit
                curr = conn.cursor()
                curr.execute('update cbis_pod set cbis_zabbix_last_sync = %s where cbis_pod_id = %s',
                             (cbis_zabbix_last_sync, self.cbis_pod_id))

                conn.commit()
            except Exception as e:
                self.log.error("ZabbixThread error: {0}".format(e))

    def _collect_pod(self, conn):

        self.log.info('connecting to %s (zabbix url : %s)' % (self.cbis_pod_name, self.cbis_zabbix_url))

        api = pyzabbix.ZabbixAPI(self.cbis_zabbix_url)

        api.session.verify = False
        api.login(user=self.cbis_zabbix_username, password=self.cbis_zabbix_password)

        hosts = api.host.get(output=['name', 'hostid'], search={'name': 'overcloud-'})

        host_ids = []
        host_data = {}

        for host in hosts:
            host_id = host['hostid']
            host_ids.append(host_id)
            host_data[host_id] = host

        items = api.item.get(hostids=host_ids,
                             monitored=True,
                             filter={'key_': self.item_keys},
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
        cbis_zabbix_last_sync_time = datetime.fromtimestamp(self.cbis_zabbix_last_sync)
        time_till = cbis_zabbix_last_sync_time + timedelta(minutes=self.period_data)
        now = datetime.now()
        has_some_collected = False
        while cbis_zabbix_last_sync_time < now and time_till < now:
            has_some_collected = True
            history_objects = []
            for item_type in items_id_from_type:
                self.log.info('Getting (%s) history.get from %s to %s for item_type %s' % (
                    self.cbis_pod_name,
                    cbis_zabbix_last_sync_time.strftime('%Y-%m-%d %H:%M:%S'),
                    time_till.strftime('%Y-%m-%d %H:%M:%S'),
                    item_type))

                for items_id_by_chunk in util.chunks(items_id_from_type[item_type], 100):
                    for i in range(4):
                        try:
                            history_objects.extend(api.history.get(itemids=items_id_by_chunk,
                                                                   history=item_type,
                                                                   time_from=int(cbis_zabbix_last_sync_time.strftime('%s')),
                                                                   time_till=int(time_till.strftime('%s')),
                                                                   sortfield=['itemid', 'clock']))
                            break
                        except Exception as e:
                            self.log.exception('error getting history (%s), retrying for %s [%s]' % (self.cbis_pod_name, i, e))

            #update begin time
            cbis_zabbix_last_sync_time = time_till
            time_till = cbis_zabbix_last_sync_time + timedelta(minutes=self.period_data)

            # raw records
            row_records = []

            # add time_till as the sync point of time
            all_clock_timestamp = [cbis_zabbix_last_sync_time.strftime('%s')]

            for history in history_objects:
                item_id = history['itemid']
                item = items_data[item_id]
                value = history['value']
                clock = history['clock']

                all_clock_timestamp.append(float(history['clock']))

                item_value_type = item['value_type']

                row_records.append({'cbis_pod_id': self.cbis_pod_id,
                                    'hostname': item['hostname'],
                                    'item_key': item['key_'],
                                    'item_value': value,
                                    'item_unit': item['units'],
                                    'clock': clock})

                if len(row_records) > 10000:
                    self._save_raw(conn, row_records)
                    row_records = []

            if len(row_records) > 0:
                self._save_raw(conn, row_records)
                row_records = []

            # mark last sync time
            if len(all_clock_timestamp) > 0:
                cbis_zabbix_last_sync = max(all_clock_timestamp)

            return cbis_zabbix_last_sync
        if not has_some_collected:
            self.log.info('Nothing to collect since current period not full period yet. ')

        return self.cbis_zabbix_last_sync

    def _save_raw(self, conn, records):
        curr = conn.cursor()

        curr.executemany(
            'INSERT INTO cbis_zabbix_raw (cbis_pod_id, hostname, item_key, item_value, item_unit, clock) '
            'VALUES (%(cbis_pod_id)s, %(hostname)s, %(item_key)s, %(item_value)s, %(item_unit)s, %(clock)s)',
            records)


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

    def partition(self):
        partition_util('cbis_zabbix_raw', 30)
        partition_util('cbis_zabbix_hour', 365)
        partition_util('cbis_zabbix_day', 365)

    def collect(self):
        self.log.info('Connecting to database')

        result_list = []

        with util.DBConnection().get_connection() as conn:

            self._conn = conn

            curr = conn.cursor()

            curr.execute('select cbis_pod_id, cbis_pod_name, cbis_zabbix_url, cbis_zabbix_username,'
                         'cbis_zabbix_password, cbis_zabbix_last_sync from cbis_pod where enable=1')

            result_list = curr.fetchall()

        all_thread = []

        for (cbis_pod_id, cbis_pod_name, cbis_zabbix_url, cbis_zabbix_username, cbis_zabbix_password,
             cbis_zabbix_last_sync) in result_list:

            thread = ZabbixThread(cbis_pod_id=cbis_pod_id,
                                  cbis_pod_name=cbis_pod_name,
                                  cbis_zabbix_url=cbis_zabbix_url,
                                  cbis_zabbix_username=cbis_zabbix_username,
                                  cbis_zabbix_password=cbis_zabbix_password,
                                  cbis_zabbix_last_sync=cbis_zabbix_last_sync,
                                  item_keys=self._item_keys,
                                  period_data=self._period_data)

            all_thread.append(thread)

        for t in all_thread:
            t.start()
        for t in all_thread:
            t.join()

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
            conn.start_transaction(isolation_level='READ COMMITTED')

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

            for records in util.chunks(hourly_records, 10000):

                curr.executemany(insert_sql, records)

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
            conn.start_transaction(isolation_level='READ COMMITTED')

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

            for records in util.chunks(daily_records, 10000):

                curr.executemany(insert_sql, records)

            conn.commit()


class CephDiskThread(threading.Thread):

    def __init__(self, cbis_pod_id, cbis_pod_name, cbis_undercloud_addr, cbis_undercloud_username):
        super(CephDiskThread, self).__init__()
        self.log = logging.getLogger(self.__class__.__name__)
        self.cbis_pod_id = cbis_pod_id
        self.cbis_pod_name = cbis_pod_name
        self.cbis_undercloud_addr = cbis_undercloud_addr
        self.cbis_undercloud_username = cbis_undercloud_username

    def run(self):

        with util.DBConnection().get_connection() as conn:

            try:
                conn.start_transaction(isolation_level='READ COMMITTED')
                kwargs = {'cbis_pod_id': self.cbis_pod_id,
                          'test_flag': False,
                          'conn': conn}

                executor = util.SshExecutor(self.cbis_undercloud_addr, self.cbis_undercloud_username, **kwargs)

                executor.run('cephstorage-*',
                             'sudo ceph-disk list | grep osd',
                             callback=self._callback_cephdisk)

                conn.commit()
            except Exception as e:
                self.log.error("CephDiskThread error: {0}".format(e))

    def _callback_cephdisk(self, hostname, line_each_node, **kwargs):
        domain_name = None
        cbis_pod_id = kwargs.get('cbis_pod_id')

        ceph_list_recoreds = []
        for line in line_each_node.splitlines():
            if not line:
                continue
            else:
                try:
                    line = line.strip()
                    values = line.split(',')
                    disk = values[0].split()[0]
                    osd = values[3].strip()
                    journal = values[4].split()[1]
                    ceph_list_recoreds.append({'cbis_pod_id': cbis_pod_id,
                                               'hostname': hostname,
                                               'disk': disk,
                                               'osd': osd,
                                               'journal': journal})
                except IndexError:
                    pass

        conn = kwargs.get('conn')

        curr = conn.cursor()

        delete_sql = 'delete from cbis_ceph_disk where cbis_pod_id = %(cbis_pod_id)s and hostname = %(hostname)s'

        curr.execute(delete_sql, {'cbis_pod_id': cbis_pod_id,
                                  'hostname': hostname})

        if len(ceph_list_recoreds) > 0:

            insert_sql = 'insert into cbis_ceph_disk (cbis_pod_id, hostname, disk, journal, osd) ' \
                         'values (%(cbis_pod_id)s, %(hostname)s, %(disk)s, %(journal)s, %(osd)s)'

            curr.executemany(insert_sql, ceph_list_recoreds)


class CephDiskCollect(object):

    def __init__(self):
        self.log = logging.getLogger(self.__class__.__name__)
        self._config = util.Config()
        self._conn = None

    def collect(self):
        self.log.info('Connecting to database')

        result_list = []

        with util.DBConnection().get_connection() as conn:

            curr = conn.cursor()

            curr.execute('select cbis_pod_id, cbis_pod_name, cbis_undercloud_addr, cbis_undercloud_username '
                         'from cbis_pod where enable=1')

            result_list = curr.fetchall()

        all_thread = []

        for (cbis_pod_id, cbis_pod_name, cbis_undercloud_addr, cbis_undercloud_username) in result_list:
            thread = CephDiskThread(cbis_pod_id=cbis_pod_id,
                                    cbis_pod_name=cbis_pod_name,
                                    cbis_undercloud_addr=cbis_undercloud_addr,
                                    cbis_undercloud_username=cbis_undercloud_username)
            all_thread.append(thread)

        for t in all_thread:
            t.start()
        for t in all_thread:
            t.join()


if __name__ == '__main__':
    PATH = os.path.dirname(os.path.abspath(__file__))
    logging.config.fileConfig(os.path.join(PATH, 'logging.ini'))
    client = ZabbixCollector()
    client.partition()
    client.collect()
