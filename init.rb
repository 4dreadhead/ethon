#!/usr/bin/env ruby
# frozen_string_literal: true

bundle_install = "bundle install"
bundle_path = "/var/app/vendor"
environment = ENV["RAKE_ENV"]

[
  "bundle config set --local without 'development test'",
  "bundle config --local path #{bundle_path}",
  "bundle config --global frozen 1"
].each do |cmd|
  puts "-> #{cmd}"
  exec cmd unless system cmd
end

# Only production gems
bundle_install = "#{bundle_install} -j 4" if ["production"].include? environment

puts "-> bundle install"
exec bundle_install unless system "#{bundle_install} --prefer-local --quiet"

args = ARGV.compact.join " "
exec_cmd = "bundle exec #{args}"
exec exec_cmd
