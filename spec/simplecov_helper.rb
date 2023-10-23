# frozen_string_literal: true

require "simplecov"

if ENV["COVERAGE"]
  SimpleCov.start do
    add_filter "spec"

    add_group "Lib", "lib"
    add_group "Parsers", "parsers"

    enable_coverage :branch
    primary_coverage :branch
  end
end
