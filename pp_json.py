#!/usr/bin/env python
# coding: utf-8
# A simple script to pretty print the given JSON string via the command line
import codecs
import json
import locale
import sys

# Wrap sys.stdout into a StreamWriter to allow writing unicode.
# It is a workaround as Python2 uses None as default encoding.
# You don't need it for Python3 whose default encoding is UTF-8.
sys.stdout = codecs.getwriter(locale.getpreferredencoding())(sys.stdout)
json_str = sys.argv[1]
data = json.loads(json_str)
print(json.dumps(data, indent=2, sort_keys=True, ensure_ascii=False))
