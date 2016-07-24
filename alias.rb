#!/usr/bin/env ruby
# encoding: UTF-8
require 'set'


def normalize_cmd cmd
  if cmd =~ /^\.\// or cmd =~ /^\.\./
    cmd = File.absolute_path cmd
  end
  if cmd.include? "'"
    cmd = '"' + cmd + '"'
  else
    cmd = "'" + cmd + "'"
  # 不存在同时有"和'，却又不对其中一个转义的情况
  end
end

if ARGV.length != 2
  puts '用法： aliashit alias_name name'
  puts 'For example, aliashit gopm "git pull own master"'
  exit 1
end

aliases = Dir.home() + '/.bash_aliases'
if ENV['SHELL'].end_with? '/zsh'
  aliases = Dir.home() + '/.zsh_aliases'
end
name = ARGV[0]
cmd = normalize_cmd(ARGV[1])
aliased = Set.new
File.new(aliases).readlines.each do |line|
  aliased.add(line.split('=').first.split.last)
end
if aliased.include? name
  puts "Warning: #{name} is used"
end
File.open(aliases, 'a+') do |f|
  f.write "alias #{name}=#{cmd}\n"
end
`alias #{name}=#{cmd}`
