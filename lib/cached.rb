# frozen_string_literal: true

require "redis"

# A module for Cached to use redis
module Cached
  def redis
    Redis.new url: ENV.fetch("REDIS_URL")
  end

  module_function :redis
end
