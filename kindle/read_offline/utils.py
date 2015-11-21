# coding: utf-8
import logging
import sys

from requests.exceptions import ConnectionError, HTTPError, Timeout
import requests

USER_AGENT = (
    'Mozilla/5.0 (X11; Linux x86_64) '
    'AppleWebKit/537.36 (KHTML, like Gecko)'
    ' Chrome/40.0.2214.115 Safari/537.36'
)
HEADERS = {'User-Agent': USER_AGENT}


def get_logger(log_level='INFO'):
    logger = logging.getLogger(__name__.split('.')[0])
    logger.setLevel(getattr(logging, log_level))
    FORMAT = '[%(levelname)s]%(filename)s:%(lineno)s %(asctime)s %(message)s'
    DATE_FORMAT = '%H:%M:%S'
    formatter = logging.Formatter(fmt=FORMAT, datefmt=DATE_FORMAT)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    return logger

logger = get_logger()


def download_html(url):
    """
    Return:
        html text if download success, else return None
    """
    if not url.startswith('http'):
        if url.startswith('www.'):
            url = 'http://' + url
        else:
            url = 'http://www.' + url
    try:
        res = requests.get(url, headers=HEADERS)
        if res.status_code in (200, 304):
            return res.html
    except (ConnectionError, HTTPError, Timeout) as e:
        logger.error(e)
    return None
