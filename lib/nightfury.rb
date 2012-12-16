require 'redis'
require 'redis-namespace'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'
require 'active_support/json'
require 'active_support/concern'

module Nightfury
  class << self
    attr_accessor :redis, :namespace

    def redis
      @redis ||= set_namespace(Redis.current)
    end

    def redis=(redis_instance)
      @redis = set_namespace(redis_instance)
    end

    def namespace
      @namespace ||= :nf
    end

    def namespace=(namespace_symbol)
      @namespace = namespace_symbol
      @redis = set_namespace(redis)
    end

    private

    def set_namespace(redis_instance)
      Redis::Namespace.new(namespace, redis: redis_instance)
    end
  end
end

require "nightfury/version"
require "nightfury/metric"
require "nightfury/metric/value"
require "nightfury/metric/time_series"
require "nightfury/identity"

