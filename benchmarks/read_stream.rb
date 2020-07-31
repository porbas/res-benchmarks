require "benchmark/ips"
require "securerandom"
require "pathname"

EVENTS_IN_STREAM = 600_000
STREAM_NAME = "test-stream"

es = RailsEventStore::Client.new

OrderCreated = Class.new(RailsEventStore::Event)

SEARCH_PATH = Pathname.new(File.expand_path("../../apps/*", __FILE__))
BASE_PATH   = Pathname.new(File.expand_path("../..", __FILE__))

customer = ("alice"*1024).freeze
ActiveRecord::Base.transaction do
  EVENTS_IN_STREAM.times do
    es.publish(OrderCreated.new(data: { customer: customer }), stream_name: STREAM_NAME)
  end
end

targets = Dir[SEARCH_PATH].map { |path| Pathname.new(path).relative_path_from(BASE_PATH).to_s.split("/")[1] }.sort

Benchmark.ips do |x|
  x.warmup = 0
  targets.each do |target|
    x.report(target) do
      es.read.stream(STREAM_NAME).in_batches.each do |e|
        e.data[:customer]
      end
    end

    x.hold! File.expand_path("../ips-state", __FILE__)
  end

  x.compare!
  x.json! BASE_PATH.join("results/read_stream.json").to_s
end
