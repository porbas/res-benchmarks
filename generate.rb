#!/usr/bin/env ruby

require "fileutils"
require "yaml"

Config = YAML.load_file("config.yml")

TARGETS = {
  "master"  => { github: "RailsEventStore/rails_event_store" },
  "v0.15.0" => "= 0.15",
  "v0.14.0" => "= 0.14",
  "v0.13.0" => "= 0.13",
  "v0.12.0" => "= 0.12",
  "v0.11.0" => "= 0.11",
  "v0.10.0" => "= 0.10",
}

RAILS_VERSION = Config.fetch("rails_version")

FileUtils.rm_rf("apps")
FileUtils.mkdir_p("apps")
Dir.chdir("apps")

Config.fetch("versions").each do |name, gem_opts|
  system("rails _#{RAILS_VERSION}_ new #{name} --skip-spring")
  File.open("#{name}/Gemfile", "a") do |f|
    f.puts("gem 'rails_event_store', #{gem_opts.inspect}")
    f.puts("gem 'benchmark-ips'")
  end
  Dir.chdir(name) do
    system("bundle install")
    system("rails g rails_event_store_active_record:migration")
  end
end
