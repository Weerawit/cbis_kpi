from __future__ import print_function
import sys
import os
import logging
import threading
import time
import subprocess
from datetime import datetime
import kpicollector


def is_process_running():
    try:
        subprocess.check_output('pgrep -f cbis-kpi-collect', shell=True)
        return True
    except Exception:
        return False


def main(args=sys.argv[1:]):
    PATH = os.path.dirname(os.path.abspath(__file__))
    logging.config.fileConfig(os.path.join(PATH, 'logging.ini'))

    log = logging.getLogger(__name__)

    if is_process_running():
        log.info('Process is running, skip current execution')
        return -1

    # arg_parser = build_parser()
    # args = arg_parser.parse_args(args)
    #
    # if args.gtime:
    #     now = args.gtime
    # else:
    now = datetime.now()
    #
    # aggregate_type = args.aggregate_type

    zabbix = kpicollector.ZabbixCollector()
    virsh = kpicollector.VirshCollector()
    cephdisk = kpicollector.CephDiskCollect()

    def cephdisk_thread():
        try:
            start_time = time.time()
            cephdisk.collect()
            log.info('cephdisk collect took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in cephdisk collect')
            log.exception(e)

    def zabbix_thread():

        try:
            start_time = time.time()
            zabbix.partition()
            log.info('zabbix partition took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in zabbix partition')
            log.exception(e)

        try:
            start_time = time.time()
            zabbix.collect()
            log.info('zabbix collect took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in zabbix collect')
            log.exception(e)

        try:
            start_time = time.time()
            zabbix.aggregate_hourly(now=float(now.strftime('%s')))
            log.info('zabbix aggregate_hourly took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in zabbix aggregate_hourly')
            log.exception(e)

        try:
            if now.hour == 1:
                start_time = time.time()
                zabbix.aggregate_daily(now=float(now.strftime('%s')))
                log.info('zabbix aggregate_daily took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in zabbix aggregate_daily')
            log.exception(e)

    def virsh_thread():

        try:
            start_time = time.time()
            virsh.partition()
            log.info('virsh partition took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in virsh partition')
            log.exception(e)

        try:
            start_time = time.time()
            virsh.collect()
            log.info('virsh collect took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in virsh collect')
            log.exception(e)

        try:
            start_time = time.time()
            virsh.aggregate_hourly(now=float(now.strftime('%s')))
            log.info('virsh aggregate_hourly took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in virsh aggregate_hourly')
            log.exception(e)

        try:
            if now.hour == 1:
                start_time = time.time()
                virsh.aggregate_daily(now=float(now.strftime('%s')))
                log.info('virsh aggregate_daily took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in virsh aggregate_daily')
            log.exception(e)

    all_thread = [threading.Thread(target=zabbix_thread),
                  threading.Thread(target=virsh_thread),
                  threading.Thread(target=cephdisk_thread)]

    for t in all_thread:
        t.start()
    for t in all_thread:
        t.join()

    log.info('process finished.')


# def build_parser():
#     """
#     Builds the argparser object
#     :return: Configured argparse.ArgumentParser object
#     """
#     def valid_date(s):
#         try:
#             return datetime.strptime(s, "%d-%m-%Y %H:%M")
#         except ValueError:
#             msg = "Not a valid date: '{0}'.".format(s)
#             raise argparse.ArgumentTypeError(msg)
#
#     parser = argparse.ArgumentParser(
#         formatter_class=argparse.ArgumentDefaultsHelpFormatter,
#         description='Collect and aggregate KPI from Zabbix and virsh. ')
#
#     parser.add_argument('--gtime',
#                         help='Time to aggregate format DD-MM-YYYY HH:MM',
#                         type=valid_date)
#
#     parser.add_argument('--aggregate_type',
#                         choices=['DAY', 'HOUR', 'ALL'],
#                         help='Aggregate Type')
#
#     return parser


if __name__ == "__main__":
    exit(main(args=sys.argv[1:]))

