module Nightfury
  module Metric
    class TimeSeries < Base
      class << self
        def floor_time(time, seconds=60)
          Time.at((time.to_f / seconds).floor * seconds)
        end

        def seconds_in_step(step_name, time)
          {
            minute: 60,
            hour: 1.hour,
            day: 1.day,
            week: 1.week,
            month: Time.days_in_month(time.month, time.year).days
          }[step_name]
        end
      end

      def initialize(name, options={})
        super(name, options)
        create unless exists?
      end

      def set(value, time=Time.now, options={})
        value, time = before_set(value, time) unless options[:skip_before_set]
        # make sure the time_series is initialized.
        # It will not if the metric is removed and
        # set is called on the smae object
        create unless exists?
        add_value_to_timeline(value, time)
      end

      def get(timestamp=nil, get_meta=false)
        return nil unless exists?
        data_point = ''
        if timestamp
          timestamp = get_step_time(timestamp).to_i
          data_points = redis.zrangebyscore(redis_key, 0, timestamp, withscores: true)
          data_point = data_points.last
        else
          data_points = redis.zrevrange(redis_key, 0, 0, withscores: true)
          data_point = data_points.last
        end

        return get_meta ? [nil, {}] : nil if data_point.nil?
        return get_meta ? [nil, {}] : nil if data_point[1].zero?

        time, data, meta_value = decode_data_point(data_point)
        get_meta ? [{time => data}, meta_value] : {time => data}
      end

      def get_exact(timestamp, get_meta=false)
        return nil unless exists?
        timestamp = get_step_time(timestamp).to_i
        data_points = redis.zrangebyscore(redis_key, timestamp, timestamp, withscores: true)
        data_point = data_points.last
        return get_meta ? [nil, {}] : nil if data_point.nil?
        time, data, meta_value = decode_data_point(data_point)
        result = get_meta ? [{time => data}, meta_value] : {time => data}
      end

      def get_range(start_time, end_time)
        return nil unless exists?
        start_time = get_step_time(start_time)
        end_time   = get_step_time(end_time)
        return unless exists?
        data_points = redis.zrangebyscore(redis_key, start_time.to_i, end_time.to_i, withscores: true)
        decode_many_data_points(data_points)
      end

      def get_all
        return nil unless exists?
        data_points = redis.zrange(redis_key,1,-1, withscores: true)
        decode_many_data_points(data_points)
      end

      def meta
        return @meta if instance_variable_defined?(:@meta)

        json = redis.zrange(redis_key, 0, 0).first
        @meta = if json
          JSON.parse(json)
        else
          {}
        end
      end

      def meta=(value)
        @meta = value
        save_meta
      end

      def default_meta
        {}
      end

      def seconds_in_step(time)
        self.class.seconds_in_step(step, time)
      end

      def floor_time(time, seconds=60)
        self.class.floor_time(time, seconds)
      end

      def get_step_time(time)
        floor_time(time, seconds_in_step(time))
      end

      def each_timestamp(start_time, end_time, &block)
        start_time = get_step_time(start_time).to_i
        end_time = get_step_time(end_time).to_i
        current_step_time, last_step_time = start_time, nil
        start_time.step(end_time, seconds_in_step(Time.at(current_step_time))) do
          yield(current_step_time, last_step_time)
          last_step_time = current_step_time
          current_step_time += seconds_in_step(Time.at(current_step_time))
        end
      end

      protected

      def before_set(value, time)
        [value, time]
      end

      def decode_data_point(data_point)
        data_point = data_point.first
        colon_index = data_point.index(':')
        [
	        data_point[0...colon_index],
	        data_point[colon_index+1..-1],
          {}
        ]
      end

      private

      def add_value_to_timeline(value, time)
        timestamp = get_step_time(time).to_i
        redis.zremrangebyscore redis_key, timestamp, timestamp
        value = "#{timestamp}:#{value}"
        redis.zadd redis_key, timestamp, value
      end

      def decode_many_data_points(data_points)
        result = {}
        data_points.each do |data_point|
          time, data = decode_data_point(data_point)
          result[time] = data
        end
        result
      end

      def save_meta
        redis.zremrangebyscore redis_key, 0, 0
        redis.zadd(redis_key, 0, meta.to_json)
      end

      def create
        redis.zadd(redis_key, 0, default_meta.to_json)
      end

      def exists?
        redis.exists(redis_key) != 0
      end
    end
  end
end
