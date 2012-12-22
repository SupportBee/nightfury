module Nightfury
  module Metric
    class TimeSeries < Base

      def initialize(name, options={})
        super(name, options)
        init_time_series unless redis.exists(redis_key)
      end

      def set(value, time=Time.now)
        value = before_set(value)
        # make sure the time_series is initialized.
        # It will not if the metric is removed and 
        # set is called on the smae object
        init_time_series unless redis.exists(redis_key)
        add_value_to_timeline(value, time)
      end
      
      def get(timestamp=nil)
        return nil unless redis.exists(redis_key)
        data_point = ''
        if timestamp
          timestamp = timestamp.to_i
          data_point = redis.zrangebyscore(redis_key, 0, timestamp, withscores: true)
          data_point = data_point.each_slice(2).map {|pair| pair }.last
        else
          data_point = redis.zrevrange(redis_key, 0, 0, withscores: true)
          data_point = data_point.each_slice(2).map {|pair| pair }.last
        end
      
        return nil if data_point.nil?
        return nil if data_point[1] == "0"

        time, data = decode_data_point(data_point)
        {time => data}
      end

      def get_range(start_time, end_time)
        return nil unless redis.exists(redis_key)        
        start_time = start_time.to_i
        end_time = end_time.to_i
        data_points = redis.zrangebyscore(redis_key, start_time, end_time, withscores: true)
        decode_many_data_points(data_points)
      end

      def get_all
        return nil unless redis.exists(redis_key)        
        data_points = redis.zrange(redis_key,1,-1, withscores: true)
        decode_many_data_points(data_points)         
      end

      def meta
        unless @meta
          json = redis.zrange(redis_key, 0, 0).first
          @meta = JSON.parse(json)
        end
        @meta
      end

      def default_meta
        {}
      end

      protected

      def before_set(value)
        value
      end

      private
      
      def add_value_to_timeline(value, time)
        time = time.to_i
        value = "#{time}:#{value}"
        redis.zadd redis_key, time, value
      end

      def decode_many_data_points(data_points)
        data_points = data_points.each_slice(2).map {|pair| pair }
        result = {}
        data_points.each do |data_point|
          time, data = decode_data_point(data_point)
          result[time] = data
        end
        result
      end

      def decode_data_point(data_point)
        data_point = data_point.first
        colon_index = data_point.index(':')

        [
          data_point[0...colon_index], 
          data_point[colon_index+1..-1]
        ]
      end

      def save_meta
        redis.zremrangebyscore redis_key, 0, 0
        redis.zadd redis_key, 0, meta.to_json 
      end

      def init_time_series
        redis.zadd redis_key, 0, default_meta.to_json
      end
    end
  end
end
