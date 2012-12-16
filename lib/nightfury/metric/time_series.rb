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
        data_point = ''
        if timestamp
          timestamp = timestamp.to_i
          data_point = redis.zrangebyscore(redis_key, timestamp, timestamp).first
        else
          data_point = redis.zrevrange(redis_key, 0, 0).first
        end

        time, data = decode_data_point(data_point)
        {time => data}
      end

      def get_range(start_time, end_time)
        start_time = start_time.to_i
        end_time = end_time.to_i

        result = {}
        data_points = redis.zrangebyscore(redis_key, start_time, end_time)
        data_points.each do |data_point|
          time, data = decode_data_point(data_point)
          result[time] = data
        end
        result
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

      def decode_data_point(data_point)
        colon_index = data_point.index(':')

        [
          data_point[0...colon_index], 
          data_point[colon_index+1..-1]
        ]
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
