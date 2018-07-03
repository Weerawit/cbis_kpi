from __future__ import print_function
import sys
import os
import logging
import threading
import time
import argparse
from datetime import datetime
import kpicollector


def main(args=sys.argv[1:]):
    PATH = os.path.dirname(os.path.abspath(__file__))
    logging.config.fileConfig(os.path.join(PATH, 'logging.ini'))

    log = logging.getLogger(__name__)

    arg_parser = build_parser()
    args = arg_parser.parse_args(args)

    if args.gtime:
        now = args.gtime
    else:
        now = datetime.now()

    aggregate_type = args.aggregate_type

    zabbix = kpicollector.ZabbixCollector()
    virsh = kpicollector.VirshCollector()
    cephdisk = kpicollector.CephDiskCollect()

    def cephdisk_thread():
        if not aggregate_type:
            try:
                start_time = time.time()
                cephdisk.collect()
                log.info('cephdisk collect took %s seconds' % (time.time() - start_time))
            except:
                log.exception('error in cephdisk collect')

    def zabbix_thread():
        if not aggregate_type:
            try:
                start_time = time.time()
                zabbix.partition()
                log.info('zabbix partition took %s seconds' % (time.time() - start_time))
            except:
                log.exception('error in zabbix partition')

            try:
                start_time = time.time()
                #zabbix.collect()
                log.info('zabbix collect took %s seconds' % (time.time() - start_time))
            except:
                log.exception('error in zabbix collect')

        if not aggregate_type or 'HOUR' in aggregate_type or 'ALL' in aggregate_type:
            try:
                start_time = time.time()
                #zabbix.aggregate_hourly(now=float(now.strftime('%s')))
                log.info('zabbix aggregate_hourly took %s seconds' % (time.time() - start_time))
            except:
                log.exception('error in zabbix aggregate_hourly')

        if not aggregate_type or 'DAY' in aggregate_type or 'ALL' in aggregate_type:
            try:
                if now.hour == 1 or (aggregate_type and ('DAY' in aggregate_type or 'ALL' in aggregate_type)):
                    start_time = time.time()
                    zabbix.aggregate_daily(now=float(now.strftime('%s')))
                    log.info('zabbix aggregate_daily took %s seconds' % (time.time() - start_time))
            except:
                log.exception('error in zabbix aggregate_daily')

    def virsh_thread():

        if not aggregate_type:
            try:
                start_time = time.time()
                virsh.partition()
                log.info('virsh partition took %s seconds' % (time.time() - start_time))
            except:
                log.exception('error in virsh partition')

            try:
                start_time = time.time()
                #virsh.collect()
                log.info('virsh collect took %s seconds' % (time.time() - start_time))
            except:
                log.exception('error in virsh collect')

        if not aggregate_type or 'HOUR' in aggregate_type or 'ALL' in aggregate_type:
            try:
                start_time = time.time()
                virsh.aggregate_hourly(now=float(now.strftime('%s')))
                log.info('virsh aggregate_hourly took %s seconds' % (time.time() - start_time))
            except:
                log.exception('error in virsh aggregate_hourly')

        if not aggregate_type or 'DAY' in aggregate_type or 'ALL' in aggregate_type:
            try:
                if now.hour == 1 or (aggregate_type and ('DAY' in aggregate_type or 'ALL' in aggregate_type)):
                    start_time = time.time()
                    virsh.aggregate_daily(now=float(now.strftime('%s')))
                    log.info('virsh aggregate_daily took %s seconds' % (time.time() - start_time))
            except:
                log.exception('error in virsh aggregate_daily')

    all_thread = [threading.Thread(target=zabbix_thread),
                  threading.Thread(target=virsh_thread),
                  threading.Thread(target=cephdisk_thread)]

    for t in all_thread:
        t.start()
    for t in all_thread:
        t.join()

    log.info('process finished.')


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
        description='Collect and aggregate KPI from Zabbix and virsh. ')

    parser.add_argument('--gtime',
                        help='Time to aggregate format DD-MM-YYYY HH:MM',
                        type=valid_date)

    parser.add_argument('--aggregate_type',
                        choices=['DAY', 'HOUR', 'ALL'],
                        help='Aggregate Type')

    return parser


if __name__ == "__main__":
    exit(main(args=sys.argv[1:]))

