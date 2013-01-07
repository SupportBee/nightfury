module Nightfury
  module Metric
    class CountTimeSeries < TimeSeries
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
