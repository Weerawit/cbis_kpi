#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import print_function
import argparse
import sys
import subprocess


def build_parser():
    """
    Builds the argparser object
    :return: Configured argparse.ArgumentParser object
    """
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
        description='Installation script of CBIS_KPI')

    parser.add_argument('action',
                        choices=['install', 'clean', 'build'],
                        help='')

    return parser


def clean():
    subprocess.check_output(['rm', '-rf', 'dist'])
    subprocess.check_output(['rm', '-rf', 'cbis_kpi.egg-info'])
    pass


def build():
    subprocess.check_output(['python', 'setup.py', 'sdist'])
    pass


def install():
    pass


def main(args=sys.argv[1:]):
    arg_parser = build_parser()
    args = arg_parser.parse_args(args)

    action = args.action
    if 'clean' == action:
        clean()
    elif 'build' == action:
        build()
    elif 'install' == action:
        install()


if __name__ == "__main__":
    exit(main(args=sys.argv[1:]))
