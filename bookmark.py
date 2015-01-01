#!/usr/bin/env python
# coding: utf-8

import argparse
from datetime import date, datetime
from collections import namedtuple
import os.path

Dir = namedtuple('Dir', ['path', 'created_at'])
# bookmark file should be created manually
Bookmarks = "/home/lzx/.config/bookmark"
DaysAgo = 2 * 30 # 2 months ago

def convert_dir_to_entry(dir_mark, dir):
    return "%s\t| %s | %s\n" % (dir_mark, dir.created_at, dir.path)

def convert_entry_to_dir(line):
    line = line.split('|')
    dir_mark = line[0].strip()
    created_at = datetime.strptime(line[1].strip(), '%Y-%m-%d').date()
    path = line[2].strip()
    return dir_mark, Dir(path=path, created_at=created_at)

def get_dir_dict():
    """
    return a dict of [dir_mark, Dir(path, created_at)]
    """
    dir_dict = {}
    try :
        with open(Bookmarks) as f :
            for line in f.readlines() :
                dir_mark, dir = convert_entry_to_dir(line)
                dir_dict[dir_mark] = dir
    except IOError :
        pass
    return dir_dict

def is_similar_to(a, b):
    return a == b

def list_dirs(marks=[]):
    dir_dict = get_dir_dict()
    matched_dir = False
    if marks != []:
        for dir_mark, dir in dir_dict.items() :
            if is_similar_to(marks[0], dir_mark) :
                matched_dir = True
                print "%s\t: %s : %s" % (dir_mark, dir.created_at, dir.path)

    if not matched_dir :
        for dir_mark, dir in dir_dict.items() :
                print "%s\t: %s : %s" % (dir_mark, dir.created_at, dir.path)

def set_dir_dict(dirs):
    with open(Bookmarks, 'w') as f :
        entries = []
        for dir_mark, dir in dirs.items() :
            entries.append(convert_dir_to_entry(dir_mark, dir))
        f.writelines(entries)

def append_dir_dict(dir_mark, dir):
    with open(Bookmarks, 'a') as f :
        f.write(convert_dir_to_entry(dir_mark, dir))

def jump_to_dir(dest):
    dir_dict = get_dir_dict()
    for dir_mark, dir in dir_dict.items() :
        if dest == dir_mark :
            return dir.path
    print "No match dir found! Maybe you want to jump to these dirs?"
    list_dirs([dest])
    return ""

def add_bookmark(path, name=None):
    path = os.path.realpath(path)
    dir_dict = get_dir_dict()
    if name is not None :
        if name in dir_dict:
            print "The given %s is existed! Try another one." % name
        else :
            append_dir_dict(name, Dir(path=path, created_at=date.today()))
            print "Add bookmark %s with path %s" % (name, path)

    else :
        basename = os.path.basename(path)
        i = 0
        name = basename[0]
        while name != basename :
            if not name in dir_dict :
                append_dir_dict(name, Dir(path=path, created_at=date.today()))
                print "Add bookmark %s with path %s" % (name, path)
                return
            else :
                i += 1
                name += basename[i]
        print "Can't guess dir_mark with given path. Try to offer a name before path"

def remove_bookmark(dir_mark):
    dir_dict = get_dir_dict()
    if dir_mark in dir_dict:
        dir_dict.pop(dir_mark)
        set_dir_dict(dir_dict)
        # list the results
        print "Remain these entries: "
        list_dirs()
    else :
        print "Given %s is not existed!" % dir_mark

def clean_bookmark():
    dir_dict = get_dir_dict()
    for dir_mark, dir in dir_dict.items() :
        if (date.today() - dir.created_at).days > DaysAgo :
            dir_dict.pop(dir_mark)
            print "remove %s : %s" % (dir_mark, dir.path)
    print "Finish cleaning bookmarks in %s" % date.today()

# start since here
parser = argparse.ArgumentParser(description=u'快速跳转当前工作目录')
subparsers = parser.add_subparsers()
parser_j = subparsers.add_parser('j', help='jump to relative dir')
parser_j.add_argument('j', nargs=1, help='dir name')

parser_a = subparsers.add_parser('a', help='add dir to dirs dict')
parser_a.add_argument('a', nargs='+')

parser_r = subparsers.add_parser('r', help='remove dir from dirs dict')
parser_r.add_argument('r', nargs=1)

parser_l = subparsers.add_parser('l', help='list dir in dirs dict')
parser_l.add_argument('l', nargs='*')

parser_c = subparsers.add_parser('c', help='clean dirs created 2 months ago')
parser_c.add_argument('c', nargs='*')

args = parser.parse_args()

if hasattr(args, 'l') :
    list_dirs(args.l)
elif hasattr(args, 'a') :
    if len(args.a) == 1 :
        add_bookmark(path=args.a[0])
    else :
        add_bookmark(name=args.a[0], path=args.a[1])
elif hasattr(args, 'r') :
    remove_bookmark(args.r[0])
elif hasattr(args, 'j') :
    print jump_to_dir(args.j[0])
elif hasattr(args, 'c') :
    clean_bookmark()
