#!/usr/bin/env ruby
# encoding: UTF-8

require 'fileutils'

SCRDIR = '/home/lzx/音乐'
DSTDIR = '/media/lzx/WIN7/Users/dell/Music/'

total_size = 0
num = 0

begin
  Dir.chdir(DSTDIR)
  existing_songlist = Dir.glob('*.mp3')
rescue Errno::ENOENT
  puts "请先挂载C盘"
  exit(1)
end

Dir.chdir(SCRDIR)
Dir.glob('*.mp3').each do |song|
  filename = File.join(SCRDIR, song)
  total_size += File.size(filename)
  num += 1
  if !(existing_songlist.include?song) && \
      File.size(filename) >= 1048576 # 1024 * 1024
    FileUtils.cp((filename), File.join(DSTDIR, song))
    puts "#{song}, copied to #{DSTDIR}"
  end
end

puts "the size of #{DSTDIR} is #{total_size / 1024 / 1024 / 1024} GB"
puts "and #{num} songs in it"

