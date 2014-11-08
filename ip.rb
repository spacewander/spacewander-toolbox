#!/usr/bin/env ruby
# encoding: UTF-8

require 'net/http'
require 'uri'
require 'json'

if ARGV.length <= 0
  puts "usage: #{$0} ip"
  exit 1
end

ip = ARGV.first
uri = URI("http://ip.taobao.com/service/getIpInfo.php?qq-pf-to=pcqq.c2c&ip=#{ip}")
res = JSON.parse(Net::HTTP.get(uri))["data"]

unless res["country"]
  puts res # invalid ip
  exit 0
end

puts "国家：  #{res["country"]}" if res["country"]
puts "区域：  #{res["area"]}" if res["area"]
puts "省份：  #{res["region"]}" if res["region"]
puts "城市：  #{res["city"]}" if res["city"]
puts "运营商：  #{res["isp"]}" if res["isp"]

