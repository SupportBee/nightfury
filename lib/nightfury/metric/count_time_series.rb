module Nightfury
  module Metric
    class CountTimeSeries < TimeSeries
      def get_padded_range(start_time, end_time)
        data_points = get_range(start_time, end_time)
        each_timestamp(start_time, end_time) do |current_step_time, last_step_time|
          current_step_time = current_step_time.to_s
          last_step_time = last_step_time.to_s
          next if data_points[current_step_time]
          data_points[current_step_time] = data_points[last_step_time]
        end
        data_points
      end

      def incr(step=1, timestamp = Time.now)
        last_data_point = get
        if last_data_point
          time, value = last_data_point.flatten
          value = value.to_i + step
          set(value, timestamp)
        else
          set(step, timestamp)
        end
      end 

      def decr(step=1, timestamp = Time.now)
        last_data_point = get
        if last_data_point
          time, value = last_data_point.flatten
          value = value.to_i - step
          set(value, timestamp)
        else
          set(-step, timestamp)
        end
      end 
    end
  end
end
