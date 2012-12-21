module Nightfury
  module Metric
    class AvgTimeSeries < TimeSeries

      def default_meta
        {'count' => 0}
      end

      protected

      def before_set(value)
        count = meta['count'] + 1
        raw = get
        current_value = raw.nil? ? 0 : raw.values.first.to_f
        result = (current_value + value) / count.to_f
        meta['count'] = count
        save_meta
        result
      end
    end
  end
end
