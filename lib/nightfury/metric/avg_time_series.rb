module Nightfury
  module Metric
    class AvgTimeSeries < TimeSeries

      def default_meta
        {'count' => 0.0, 'total' => 0.0}
      end

      protected

      def before_set(value)
        updated_count = meta['count'].to_f + 1.0
        updated_total = meta['total'].to_f + value
        result = updated_total / updated_count
        meta['count'] = updated_count
        meta['total'] = updated_total
        save_meta
        result
      end
    end
  end
end
