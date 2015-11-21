#!/usr/bin/env python
# coding: utf-8

from __future__ import print_function
import argparse
import importlib
import sys


def parse_argv(argv=None):
    parser = argparse.ArgumentParser(
        prog='read_offline',
        description='从在线阅读网站中下载txt小说'
    )
    parser.add_argument(
        'url',
        type=str,
        help='小说链接'
    )
    parser.add_argument(
        '-f', '--from',
        dest='website',
        required=True,
        help='网站名'
    )
    if argv is None:
        argv = parser.parse_args()
    else:
        argv = parser.parse_args(argv)
    return {'website': argv.website, 'url': argv.url}


def main():
    argv = parse_argv()
    website = argv['website']
    url = argv['url']
    try:
        # load module according to specific website
        website_lib = importlib.import_module('.' + website,
                                              'read_offline.websites')
        website_lib.download_txt_from(url)
    except ImportError:
        print("website %s has not been supported yet" % website,
              file=sys.stderr)

if __name__ == '__main__':
    main()
