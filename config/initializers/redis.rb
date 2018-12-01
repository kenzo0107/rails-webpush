# frozen_string_literal: true

require 'redis'

class RedisRegistry
  thread_mattr_accessor :redis
end

def redis
  host = ENV['RAILS_REDIS_HOST'] || Rails.application.credentials.dig(Rails.env.to_sym, :redis, :host)
  port = ENV['RAILS_REDIS_PORT'] || Rails.application.credentials.dig(Rails.env.to_sym, :redis, :port)
  RedisRegistry.redis ||= Redis.new(host: host, port: port)
end
