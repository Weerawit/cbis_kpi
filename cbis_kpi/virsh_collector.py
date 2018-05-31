from __future__ import print_function

import logging
import os
import logging.config
import time
import collections
import util
import xml.etree.ElementTree as ET
from datetime import timedelta, datetime
from util.ssh_executor import SshExecutor


class VirshCollector(object):

    def __init__(self):
        self.log = logging.getLogger(self.__class__.__name__)
        self._config = util.Config()
        self._load_config()
        self._conn = None

    def _load_config(self):
        pass

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
        self._partition_util('cbis_virsh_stat_raw', 14)
        self._partition_util('cbis_virsh_stat_hour', 90)
        self._partition_util('cbis_virsh_stat_day', 365)

    def collect(self):
        self.log.info('Connecting to database')

        with util.DBConnection().get_connection() as conn:

            self._conn = conn

            curr = conn.cursor()

            curr.execute('select cbis_pod_id, cbis_pod_name, cbis_undercloud_addr, cbis_undercloud_username,'
                         'cbis_undercloud_last_sync from cbis_pod where enable=1')

            for (cbis_pod_id, cbis_pod_name, cbis_undercloud_addr, cbis_undercloud_username,
                 cbis_undercloud_last_sync) in curr:
                cbis_undercloud_current_sync = time.time()
                kwargs = {'cbis_undercloud_last_sync': cbis_undercloud_last_sync,
                          'cbis_pod_id': cbis_pod_id,
                          'cbis_undercloud_current_sync': cbis_undercloud_current_sync,
                          'test_flag': False}

                executor = SshExecutor(cbis_undercloud_addr, cbis_undercloud_username, **kwargs)

                executor.run('compute-*',
                             'sudo virsh list | head -n -1 | tail -n +3 | awk \"{ system(\\\"sudo virsh dumpxml \\\" \$2)}\"',
                             callback=self._callback_dumpxml)

                executor.run('compute-*',
                             'sudo virsh list | head -n -1 | tail -n +3 | awk \"{ system(\\\"sudo virsh domstats \\\" \$2)}\"',
                             callback=self._callback_stat)

                curr.execute('update cbis_pod set cbis_undercloud_last_sync = %s where cbis_pod_id = %s',
                             (cbis_undercloud_current_sync, cbis_pod_id))
                conn.commit()

            curr.close()

    def _callback_dumpxml(self, hostname, line_each_node, **kwargs):
        cbis_pod_id = kwargs.get('cbis_pod_id')
        virsh_list_records = []
        domain_xml = ""
        found_domain = False
        for line in line_each_node.splitlines():
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

        conn = self._conn

        curr = conn.cursor()

        delete_sql = 'delete from cbis_virsh_list where cbis_pod_id = %(cbis_pod_id)s and hostname = %(hostname)s'

        curr.execute(delete_sql, {'cbis_pod_id': cbis_pod_id,
                                  'hostname': hostname})

        insert_sql = 'insert into cbis_virsh_list (cbis_pod_id, hostname, domain_name, vm_name, vm_flavor, vm_vcpu, vm_memory, vm_numa) ' \
                     'values (%(cbis_pod_id)s, %(hostname)s, %(domain_name)s, %(vm_name)s, %(vm_flavor)s, %(vm_vcpu)s, %(vm_memory)s, %(vm_numa)s)'
        curr.executemany(insert_sql, virsh_list_records)

        curr.close()

    def _parse_xml(self, hostname, domain_xml, **kwargs):
        cbis_pod_id = kwargs.get('cbis_pod_id')
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
        for interface_root in root.findall(".//interface"):
            if "hostdev" == interface_root.attrib['type']:
                is_sriov = True
                break

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
                'has_writeback': has_writeback}

    def _callback_stat(self, hostname, line_each_node, **kwargs):
        domain_name = None
        cbis_undercloud_last_sync = kwargs.get('cbis_undercloud_last_sync')
        cbis_undercloud_current_sync = kwargs.get('cbis_undercloud_current_sync')
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

        conn = self._conn

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
                                                       'clock': cbis_undercloud_current_sync
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
                                                       'clock': cbis_undercloud_current_sync
                                                      })

        insert_sql = 'insert into cbis_virsh_stat_raw (cbis_pod_id, domain_name, item_key, item_value, item_delta, clock) ' \
                     'values (%(cbis_pod_id)s, %(domain_name)s, %(item_key)s, %(item_value)s, %(item_delta)s, %(clock)s)'
        curr.executemany(insert_sql, cbis_virsh_stat_raw_values)

        curr.close()

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

            curr.executemany(insert_sql, hourly_records)

            curr.close()

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

            curr.executemany(insert_sql, daily_records)

            curr.close()

            conn.commit()


if __name__ == '__main__':
    PATH = os.path.dirname(os.path.abspath(__file__))
    logging.config.fileConfig(os.path.join(PATH, 'logging.ini'))
    client = VirshCollector()
    client.collect()
