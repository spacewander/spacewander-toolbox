# coding: utf-8
from __future__ import print_function
import sys

from bs4 import BeautifulSoup

from ..utils import download_html, logger


def download_txt_from(url):
    html = download_html(url)
    if html is None:
        logger.error('Download txt failed.')
        sys.exit(-1)
    soup = BeautifulSoup(html, 'html.parser')
    print(html)
