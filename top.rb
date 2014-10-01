#!/usr/bin/env ruby
# encoding: UTF-8

require 'optparse'
OptionParser.new do |opts|
  opts.banner = """
    用法: 
    #{$0} -h 显示帮助
    #{$0} cmd 显示某个命令的使用次数
    #{$0} 显示最常用的30个命令
  """

  opts.on("-h", "--help", "print help message") do |f|
    puts opts.banner
    exit(0)
  end

  begin
    opts.parse!
  rescue OptionParser::InvalidOption
    puts opts.banner
    exit(0)
  end
end

# 显示最常用的命令（通过读取历史文件）
# 同时加入一个按输入字符串来查找某个命令的使用次数的功能

def query result, query
  # result的结构是[[cmd, used_times], ...]
  idx = result.index {|elem| elem[0] == query}
  if idx != nil
    puts "#{query} is used for #{result[idx][1]} times"
  else
    puts "#{query} has not been used before"
  end
end

def rank result, num
  num = result.length if num > result.length
  puts "RANK\tCMD\t\tCOUNT"
  (0...num).each {|i| puts "#{i}:\t#{result[i][0]}\t\t#{result[i][1]}"}
end

history = []
files = ['/home/lzx/zsh_his1', '/home/lzx/.zsh_history']
files.each do |filename|
  File.new(filename).each_line do |line|
    if line.index(';')
      begin 
        # the delimitor only for zsh
        history.push(line.split(';')[1].split(' ')[0])
      rescue Exception
        # do nothing
      end
    end

  end
end

rank = {}
history.each do |line|
  rank[line] ||= 0
  rank[line] += 1
end

result = rank.entries().sort {|a, b| b[1] <=> a[1]}

ARGV[0].nil? ? num = 30 : num = ARGV[0].to_i()
# 增加一个查询功能
if num == 0 # 如果是没法转换成数字的字符串，那么作为查询字符串显示
  query(result, ARGV[0])
else
  rank(result, num)
end
