#!/usr/bin/env ruby
# encoding: UTF-8

# the ruby version of `wc -l`, print the result in the table style of Markdown

require 'optparse'

def count_file_lines filename
  f = File.new filename
  count = 0
  f.each_line { |line| count += 1 }
  count
end

def get_total_result sum
  if sum.nil?
    p "ERROR: the result is nil"
    exit 1
  end
  total = 0
  sum.each_key do |item|
    total += sum[item]
  end
  sum["total"] = total
end

def filter_argv_check sum, patterns
  if !sum.instance_of?(Hash) || patterns.nil?
    p "ERROR: ARGV is invalid"
    exit 1
  end
end

# count files matched the patterns
# and only print the total result
def filter_only_total sum, patterns
  patterns.each do |pattern|
    Dir.glob("#{pattern}").each do |matched|
      file_length = count_file_lines matched
      sum[matched] = file_length
    end
  end
  get_total_result sum
  # filter items except 'total'
  sum.delete_if {|key| key != 'total'}
end

# count files matched the patterns
# and filter the result according with filename, then store it in Hash sum
def filter_with_file sum, patterns
  patterns.each do |pattern|
    Dir.glob("#{pattern}").each do |matched|
      file_length = count_file_lines matched
      sum[matched] = file_length
    end
  end
  get_total_result sum
end

# count files matched the patterns
# and filter the result according with dirname, then store it in Hash sum
def filter_with_dir sum,patterns
  patterns.each do |pattern|
    Dir.glob("#{pattern}").each do |matched|
      file_length = count_file_lines matched
      path = matched.split('/')
      if path.length > 1
        dirname = path[0]
      else
        dirname = '.'
      end
      sum[dirname] ||= 0
      sum[dirname] += file_length
    end
  end
  get_total_result sum
end

if ARGV.length < 2
  puts "USAGE: #{$0} [-o|-d|-f] pattern1[, pattern2, ...]"
  exit 1
end

options = {
  'method' => 'file'
}

OptionParser.new do |opts|
  opts.banner = "USAGE: #{$0} [-o|-d|-f] pattern1[, pattern2, ...]"

  opts.on("-f", "filter with file[default option]") do |f|
    options['method'] = 'file'
  end

  opts.on("-d", "filter with directory") do |f|
    options['method'] = 'directory'
  end

  opts.on("-o", "only print the total line number") do |f|
    options['method'] = 'only'
  end

end.parse!

p options
sum = {}
patterns = ARGV.uniq

filter_argv_check sum, patterns
case options['method']
  when 'file'
    filter_with_file sum, patterns
  when 'directory'
    filter_with_dir sum, patterns
  when 'options'
    filter_only_total sum, patterns
end

# dir[1] == item  dir[0] == num
sum.each { |dir| puts "#{dir[1]}\t#{dir[0]}"}

