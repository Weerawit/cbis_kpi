from __future__ import print_function
import sys
import os
import logging.config
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

    now = args.date

    aggregate_type = args.aggregate_type

    zabbix = kpicollector.ZabbixCollector()
    virsh = kpicollector.VirshCollector()

    if aggregate_type == 'HOUR' or aggregate_type == 'ALL':
        try:
            start_time = time.time()
            zabbix.aggregate_hourly(now=float(now.strftime('%s')))
            log.info('zabbix aggregate_hourly took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in zabbix aggregate_hourly')
            log.exception(e)

        try:
            start_time = time.time()
            virsh.aggregate_hourly(now=float(now.strftime('%s')))
            log.info('virsh aggregate_hourly took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in virsh aggregate_hourly')
            log.exception(e)

    if aggregate_type == 'DAY' or aggregate_type == 'ALL':
        try:
            start_time = time.time()
            zabbix.aggregate_daily(now=float(now.strftime('%s')))
            log.info('zabbix aggregate_daily took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in zabbix aggregate_daily')
            log.exception(e)

        try:
            start_time = time.time()
            virsh.aggregate_daily(now=float(now.strftime('%s')))
            log.info('virsh aggregate_daily took %s seconds' % (time.time() - start_time))
        except Exception as e:
            log.exception('error in virsh aggregate_daily')
            log.exception(e)



def build_parser():
    """
    Builds the argparser object
    :return: Configured argparse.ArgumentParser object
    """
    def valid_date(s):
        try:
            date = datetime.strptime(s, "%d-%m-%Y %H")
            if date >= datetime.now():
                raise argparse.ArgumentTypeError('{0} should be less then current date'.format(s))
            return date
        except ValueError:
            msg = "Not a valid date: '{0}'.".format(s)
            raise argparse.ArgumentTypeError(msg)

    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description='Aggeregate KPI ')

    parser.add_argument('--date',
                        help='Date format DD-MM-YYYY HH',
                        required=True,
                        type=valid_date)

    parser.add_argument('--aggregate_type',
                        required=True,
                        choices=['DAY', 'HOUR', 'ALL'],
                        help='Aggregate Type')

    return parser


if __name__ == "__main__":
    exit(main(args=sys.argv[1:]))