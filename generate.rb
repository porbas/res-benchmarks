#!/usr/bin/env ruby

require "fileutils"
require "yaml"
require "tmpdir"

Config = YAML.load_file("config.yml")
RAILS_VERSION = Config.fetch("rails_version")
VERSIONS = Config.fetch("versions")

FileUtils.rm_rf("apps")
FileUtils.mkdir_p("apps")
Dir.chdir("apps")

Dir.mktmpdir do |dir|
  gemfile = File.join(dir, "Gemfile")
  File.open(gemfile, "w") do |f|
    f.puts("source 'https://rubygems.org'")
    f.puts("gem 'rails', '= #{RAILS_VERSION}'")
  end
  system("bundle install --gemfile=#{gemfile}")

  VERSIONS.each do |name, gem_opts|
    system({"BUNDLE_GEMFILE" => gemfile}, "bundle exec rails new #{name} --skip-spring --database=postgresql")
    File.open("#{name}/Gemfile", "a") do |f|
      f.puts("gem 'rails_event_store', #{gem_opts.inspect}")
      f.puts("gem 'benchmark-ips'")
    end
    Dir.chdir(name) do
      system("bundle install")
      system("rails g rails_event_store_active_record:migration")
    end
  end
end
