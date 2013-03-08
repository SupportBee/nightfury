module Nightfury
  module Metric
    class TimeSeries < Base
      
      def self.floor_time(time, seconds=60)
        Time.at((time.to_f / seconds).floor * seconds)
      end

      def initialize(name, options={})
        super(name, options)
        init_time_series unless redis.exists(redis_key)
      end

      def set(value, time=Time.now, options={})
        value, time = before_set(value, time) unless options[:skip_before_set]
        # make sure the time_series is initialized.
        # It will not if the metric is removed and 
        # set is called on the smae object
        init_time_series unless redis.exists(redis_key)
        add_value_to_timeline(value, time)
      end
      
      def get(timestamp=nil, get_meta=false)
        return nil unless redis.exists(redis_key)
        data_point = ''
        if timestamp
          timestamp = get_step_time(timestamp).to_i
          data_point = redis.zrangebyscore(redis_key, 0, timestamp, withscores: true)
          data_point = data_point.each_slice(2).map {|pair| pair }.last
        else
          data_point = redis.zrevrange(redis_key, 0, 0, withscores: true)
          data_point = data_point.each_slice(2).map {|pair| pair }.last
        end
      
        return get_meta ? [nil, {}] : nil if data_point.nil?
        return get_meta ? [nil, {}] : nil if data_point[1] == "0"

        time, data, meta_value = decode_data_point(data_point)
        get_meta ? [{time => data}, meta_value] : {time => data}
      end

      def get_exact(timestamp, get_meta=false)
        return nil unless redis.exists(redis_key)
        timestamp = get_step_time(timestamp).to_i
        data_point = redis.zrangebyscore(redis_key, timestamp, timestamp, withscores: true)
        data_point = data_point.each_slice(2).map {|pair| pair }.last
        return get_meta ? [nil, {}] : nil if data_point.nil?
        time, data, meta_value = decode_data_point(data_point)
        result = get_meta ? [{time => data}, meta_value] : {time => data}
      end

      def get_range(start_time, end_time)
        return nil unless redis.exists(redis_key)        
        start_time = get_step_time(start_time).to_i
        end_time   = get_step_time(end_time).to_i
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

      def meta=(value)
        @meta = value
        save_meta
      end

      def default_meta
        {}
      end

      protected

      def before_set(value, time)
        [value, time]
      end

      def decode_data_point(data_point)
        [data_point[1], data_point[0], {}]
      end

      def floor_time(time, seconds=60)
        self.class.floor_time(time, seconds)
      end

      def get_step_time(time)
        case step
          when :minute then floor_time(time, 60)
          when :hour then floor_time(time, 1.hour)
          when :day then floor_time(time, 1.day)
          when :week then floor_time(time, 1.week)
          when :month then floor_time(time, Time.days_in_month(time.month, time.year))
        end
      end

      private
      
      def add_value_to_timeline(value, time)
        timestamp = get_step_time(time).to_i
        redis.zadd redis_key, timestamp, value
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
