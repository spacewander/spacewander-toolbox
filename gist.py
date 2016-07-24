#!/usr/bin/env python
# coding: utf-8
from __future__ import print_function
import codecs
import os
import sys
import textwrap
import requests


if __name__ == '__main__':
    if len(sys.argv) != 2:
        help_info = '''\
        Usage: %s [gist]
        gist: gist id or gist url

        Download the content to a file if there is only one file in given gist,
        else create a directory with given [gist] and store each file in it.'''
        print(textwrap.dedent(help_info), file=sys.stderr)
        sys.exit(-1)
    _, _, gist = sys.argv[1].rpartition('/')
    url = 'https://api.github.com/gists/%s' % gist
    res = requests.get(url)
    if res.status_code in (200, 304):
        data = res.json()
    else:
        raise requests.exceptions.HTTPError(res)
    if len(data['files']) == 1:
        filename = data['files'].values[0]['filename']
        print('Download %s' % filename)
        with codecs.open(filename, 'w', encoding='utf-8') as f:
            f.write(data['files'].values[0]['content'])
    else:
        os.mkdir(gist)
        print('Create gist directory %s' % gist)
        os.chdir(gist)
        for file_info in data['files'].values():
            filename = file_info['filename']
            print('Download %s' % filename)
            with codecs.open(filename, 'w', encoding='utf-8') as f:
                f.write(file_info['content'])
