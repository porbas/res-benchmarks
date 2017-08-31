#!/usr/bin/env ruby

################################################################################################
# Copied from https://github.com/evanphx/benchmark-ips/blob/master/lib/benchmark/ips/share.rb  #
################################################################################################

require 'net/http'
require 'net/https'
require 'json'

DEFAULT_URL = "https://benchmark.fyi"

base = (ENV['SHARE_URL'] || DEFAULT_URL)
url = URI(File.join(base, "reports"))

report = JSON.parse(File.read(ARGV[0])).sort { |l,r| r["ips"] <=> l["ips"] }

req = Net::HTTP::Post.new(url)

req.body = JSON.generate(
  "entries" => report,
  "options" => { "compare" => true }
)

http = Net::HTTP.new(url.hostname, url.port)
if url.scheme == "https"
  http.use_ssl = true
  http.ssl_version = :TLSv1_2
end

res = http.start do |h|
  h.request req
end

if Net::HTTPOK === res
  data = JSON.parse res.body
  puts "Shared at: #{File.join(base, data["id"])}"
else
  puts "Error sharing report"
end
