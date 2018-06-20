from __future__ import print_function

import logging
import os
import sys
import logging.config
import argparse
import collections
import util
from datetime import datetime


class VirshExporter(object):

    def __init__(self):
        self.log = logging.getLogger(self.__class__.__name__)
        self._config = util.Config()
        self._conn = None

    def export_raw(self):
        pass

    def export_hour(self):
        pass

    def export_day(self):
        pass


def main(args=sys.argv[1:]):
    path = os.path.dirname(os.path.abspath(__file__))
    logging.config.fileConfig(os.path.join(path, 'logging.ini'))

    log = logging.getLogger(__name__)

    arg_parser = build_parser()
    args = arg_parser.parse_args(args)

    from_date = args.from_date
    to_date = args.to_date
    export_type = args.export_type




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
        description='Export KPI to CVS file. ')

    parser.add_argument('--from_date',
                        help='start date to export format DD-MM-YYYY HH:MM',
                        type=valid_date)

    parser.add_argument('--to_date',
                        help='end date to export format DD-MM-YYYY HH:MM',
                        default=datetime.now(),
                        type=valid_date)

    parser.add_argument('--export_type',
                        choices=['DAY', 'HOUR', 'RAW', 'ALL'],
                        default='ALL',
                        help='Export data Type')

    return parser


if __name__ == "__main__":
    exit(main(args=sys.argv[1:]))