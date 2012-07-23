#!/usr/bin/env ruby-local-exec

require "bundler/setup"
require "pathological"
require "environment"

command = "bundle exec sequel -m migrations/"
db_url = "postgres://#{DB_USER}:#{DB_PASS}@#{DB_HOST}/#{DB_NAME}"
version = ARGV[0]
puts `#{command} #{db_url} -M #{version}`
