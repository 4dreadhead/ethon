# frozen_string_literal: true

port ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAKE_ENV") { "development" }
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }
