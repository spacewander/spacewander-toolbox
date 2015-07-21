#!/usr/bin/env ruby
# encoding: UTF-8

# 统计给出一组数，算得出24点的概率有多大
`g++ -g -std=c++11 ./24.cpp`
found = 0
count = 0.0

chooses = (1..13).to_a
chooses.product(chooses, chooses, chooses) do |ary|
  IO.popen("./a.out #{ary[0]} #{ary[1]} #{ary[2]} #{ary[3]}") do |f|
    res = f.read.chomp
    found += 1 if res != "Not Found"
    count += 1
    if count % 50 == 0
      sleep 1
      p ary
      puts "found / count: #{found / count}"
    end
  end
end

puts found / count # Final result: 56.1%
