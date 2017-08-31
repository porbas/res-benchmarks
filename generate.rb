#!/usr/bin/env ruby

require "fileutils"
require "yaml"

Config = YAML.load_file("config.yml")
RAILS_VERSION = Config.fetch("rails_version")
VERSIONS = Config.fetch("versions")

FileUtils.rm_rf("apps")
FileUtils.mkdir_p("apps")
Dir.chdir("apps")

VERSIONS.each do |name, gem_opts|
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
