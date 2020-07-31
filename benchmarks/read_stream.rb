require "benchmark/ips"
require "securerandom"
require "pathname"

EVENTS_IN_STREAM = 50
STREAM_NAME = "test-stream"

es = RailsEventStore::Client.new

OrderCreated = Class.new(RailsEventStore::Event)

SEARCH_PATH = Pathname.new(File.expand_path("../../apps/*", __FILE__))
BASE_PATH   = Pathname.new(File.expand_path("../..", __FILE__))

EVENTS_IN_STREAM.times do
  es.publish(OrderCreated.new(data: { customer: "alice" }), stream_name: STREAM_NAME)
end

targets = Dir[SEARCH_PATH].map { |path| Pathname.new(path).relative_path_from(BASE_PATH).to_s.split("/")[1] }.sort

Benchmark.ips do |x|
  targets.each do |target|
    x.report(target) do
      es.read.stream(STREAM_NAME).to_a
    end

    x.hold! File.expand_path("../ips-state", __FILE__)
  end

  x.compare!
  x.json! BASE_PATH.join("results/read_stream.json").to_s
end
