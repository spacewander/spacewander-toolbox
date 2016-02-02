# coding: utf-8
from __future__ import print_function
import sys

from bs4 import BeautifulSoup

from ..utils import download_html, logger


# www.sto.cc 思兔阅读 繁体网站 主要是推理小说
def download_txt_from(url):
    content, last_url = download_page_from(url, is_first=True)
    end_url = generate_next_url(last_url)
    url = generate_next_url(url)
    while url != end_url:
        content += download_page_from(url)
        url = generate_next_url(url)
    return content


def download_page_from(url, is_first=False):
    html = download_html(url)
    if html is None:
        logger.error('Download txt failed.')
        sys.exit(-1)
    soup = BeautifulSoup(html, 'html.parser')
    main = soup.find(id='BookContent')
    soup.find(id='a_d_1').extract()
    soup.find(id='a_d_2').extract()
    book_content = u''
    for e in main.contents:
        if e.name == 'br':
            book_content += '\n'
        elif e.string is not None:
            book_content += e.string
    book_content = book_content.strip()
    if not is_first:
        return book_content
    else:
        pages = soup.find(id='webPage')
        # 最末页的链接在倒数第二个元素
        last_anchor = pages.contents[-2]
        last_url = url[:-1].rpartition('/')[0] + last_anchor['href']
        logger.info('Get last_url %s' % last_url)
        return book_content, last_url


def generate_next_url(url):
    """
    Make sure given url ends with '/',
    the returned url should end with '/' too.
    """
    host, _, path = url[:-1].rpartition('/')
    book_id, _, page_num = path.partition('-')
    next_url = host + '/' + book_id + '-' + str(int(page_num) + 1) + '/'
    return next_url
