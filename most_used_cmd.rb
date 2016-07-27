#!/usr/bin/env ruby
# encoding: UTF-8

# use $0 zsh to print cmd usage in zsh, othrwise bash's result will be output
cmd_history = Hash.new(0)
historys = []
if ARGV.length == 1 and ARGV[0] == 'zsh'
  historys = File.new("#{Dir.home()}/.zsh_history").readlines[-1000..-1]
  # some entries without ';'
  historys.map!{|x| x.split(';', 2).last.chomp!.split.first}
else
  historys =
    IO.popen("echo 'history | tail -n 1000' | bash -i 2>/dev/null").readlines()
  if historys.first =~ /\A\s+\d+\*?\s+\d\d\d\d-\d\d-\d\d \d\d:\d\d/
    historys.map!{|x| x.split[3..-1].first}
  end
end
historys.each do |cmd|
  cmd_history[cmd] += 1
end

# Got EPIPE with `head` when too much bytes are written
cmd_history.delete_if {|k, v| v == 1} if cmd_history.length > 100
longest_cmd = cmd_history.keys.max_by(&:length)
cmd_history.to_a.sort {|a, b| b[1] <=> a[1]}.each_with_index do |x, i|
  printf "%-#{longest_cmd.length}s %s\t%s\n", x[0], x[1], i+1
end
