from __future__ import print_function
import sys
import os
import logging
import threading
import time
from datetime import datetime
from zabbix_collector import ZabbixCollector
from virsh_collector import VirshCollector


def main(args=sys.argv[1:]):
    PATH = os.path.dirname(os.path.abspath(__file__))
    logging.config.fileConfig(os.path.join(PATH, 'logging.ini'))

    log = logging.getLogger(__name__)

    now = datetime.now()

    zabbix = ZabbixCollector()
    virsh = VirshCollector()

    def zabbix_thread():
        try:
            start_time = time.time()
            zabbix.partition()
            log.info('zabbix partition took %s seconds' % (time.time() - start_time))
        except Exception:
            log.exception('error in zabbix partition')

        try:
            start_time = time.time()
            zabbix.collect()
            log.info('zabbix collect took %s seconds' % (time.time() - start_time))
        except Exception:
            log.exception('error in zabbix collect')

        try:
            start_time = time.time()
            zabbix.aggregate_hourly()
            log.info('zabbix aggregate_hourly took %s seconds' % (time.time() - start_time))
        except Exception:
            log.exception('error in zabbix aggregate_hourly')

        try:
            if now.hour == 1:
                start_time = time.time()
                zabbix.aggregate_daily()
                log.info('zabbix aggregate_daily took %s seconds' % (time.time() - start_time))
        except Exception:
            log.exception('error in zabbix aggregate_daily')

    def virsh_thread():

        try:
            start_time = time.time()
            virsh.partition()
            log.info('virsh partition took %s seconds' % (time.time() - start_time))
        except Exception:
            log.exception('error in virsh partition')

        try:
            start_time = time.time()
            virsh.collect()
            log.info('virsh collect took %s seconds' % (time.time() - start_time))
        except Exception:
            log.exception('error in virsh collect')
        try:
            start_time = time.time()
            virsh.aggregate_hourly()
            log.info('virsh aggregate_hourly took %s seconds' % (time.time() - start_time))
        except Exception:
            log.exception('error in virsh aggregate_hourly')
        try:
            if now.hour == 1:
                start_time = time.time()
                virsh.aggregate_daily()
                log.info('virsh aggregate_daily took %s seconds' % (time.time() - start_time))
        except Exception:
            log.exception('error in virsh aggregate_daily')

    all_thread = [threading.Thread(target=zabbix_thread), threading.Thread(target=virsh_thread)]

    for t in all_thread:
        t.start()
    for t in all_thread:
        t.join()

    log.info('process finished.')


if __name__ == "__main__":
    exit(main(args=sys.argv[1:]))

