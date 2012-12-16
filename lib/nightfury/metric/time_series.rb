require 'json'

module Nightfury
  module Metric
    class TimeSeries < Base
      def set(value, time=Time.now)
        value = before_set(value)
        init_time_series unless redis.exists(redis_key)
        add_value_to_timeline(value, time)
      end
      
      def get(timestamp=nil)
        
      end

      def get_range
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
