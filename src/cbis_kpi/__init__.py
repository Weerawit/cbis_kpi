from __future__ import print_function
import sys
import os
import logging
import threading
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
        zabbix.collect()
        zabbix.aggregate_hourly()
        if now.hour == 1:
            zabbix.aggregate_daily()

    def virsh_thread():
        virsh.collect()
        virsh.aggregate_hourly()
        if now.hour == 1:
            virsh.aggregate_daily()

    all_thread = [threading.Thread(target=zabbix_thread), threading.Thread(target=virsh_thread)]

    for t in all_thread:
        t.start()
    for t in all_thread:
        t.join()

    log.info('process finished.')


if __name__ == "__main__":
    exit(main(args=sys.argv[1:]))

