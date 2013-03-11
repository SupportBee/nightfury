module Nightfury
  module Metric
    class CountTimeSeries < TimeSeries
      def get_padded_range(start_time, end_time)
        data_points = get_range(start_time, end_time)
        each_timestamp(start_time, end_time) do |current_step_time, last_step_time|
          current_step_time = current_step_time.to_s
          last_step_time = last_step_time.to_s
          next if data_points[current_step_time]
          data_points[current_step_time] = 0.to_s
        end
        Hash[data_points.sort]
      end

      def incr(step=1, time = Time.now)
        value = 0
        step_time = get_step_time(time)
        data_point = get_exact(step_time)
        value = data_point.flatten[1] unless data_point.nil?
        updated_value = value.to_i + step
        set(updated_value, step_time) 
      end 

      def decr(step=1, time = Time.now)
        value = 0
        step_time = get_step_time(time)
        data_point = get_exact(step_time)
        value = data_point.flatten[1] unless data_point.nil?
        updated_value = value.to_i - step
        set(updated_value, step_time)
      end
    end
  end
end
