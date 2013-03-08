module Nightfury
  module Metric
    class AvgTimeSeries < TimeSeries
      def get_padded_range(start_time, end_time)
        data_points = get_range(start_time, end_time)
        each_timestamp(start_time, end_time) do |current_step_time, last_step_time|
          current_step_time = current_step_time.to_s
          last_step_time = last_step_time.to_s
          next if data_points[current_step_time]
          data_points[current_step_time] = '0.0'
        end
        data_points
      end

      protected

      def before_set(value, time)
        step_time = get_step_time(time)
        data_point, meta_value = get_exact(step_time, true)
        current_count = current_total = 0.0
        unless data_point.nil?
          current_count = meta_value[:current_count].to_f
          current_total = meta_value[:current_total].to_f
        end
        updated_count = current_count + 1.0
        updated_total = current_total + value
        result = updated_total / updated_count
        result = "#{updated_count},#{updated_total},#{result}"
        [result, time]
      end

      def decode_data_point(data_point)
        current_count, current_total, data = data_point[0].split(',')
        [data_point[1], data, {current_count: current_count, current_total: current_total}]
      end
    end
  end
end
