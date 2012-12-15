require 'json'

module Nightfury
  module Metric
    class Base      
      attr_reader :name, :redis, :redis_key_prefix
      
      def initialize(name, options={})
        @name = name
        @redis = Nightfury.redis
        @redis_key_prefix = options[:redis_key_prefix]
      end

      def redis_key
        prefix = redis_key_prefix.blank? ? '' : "#{redis_key_prefix}:"
        "#{prefix}metric:#{name}" 
      end
    end


    class Value < Base
      def set(value)
        value = before_set(value)
        redis.set(redis_key, value)
      end

      def get
        redis.get(redis_key)
      end

      def incr
        redis.incr(redis_key)
      end
    
      def decr
        redis.decr(redis_key)
      end

      private

      def before_set(value)
        value
      end
    end

  
    class TimeSeries < Base

      def set(value, time=Time.now)
        value = before_set(value)
        init_time_series unless redis.exists(redis_key)
        add_value_to_timeline(value, time)
      end
      
      def meta
        json = redis.zrange(redis_key, 0, 0).first
        JSON.parse(json)
      end

      def default_meta
        {}
      end

      private
      
      def add_value_to_timeline(value, time)
        time = time.to_i
        value = "#{time}:#{value}"
        redis.zadd redis_key, time, value
      end

      def before_set(value)
        value
      end

      def init_time_series
        redis.zadd redis_key, 0, default_meta.to_json
      end
    end
  end
end


