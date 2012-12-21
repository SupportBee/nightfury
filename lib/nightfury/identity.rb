module Nightfury
  module Identity
    class Base

      METRIC_MAPPINGS = {
            :value => Nightfury::Metric::Value,
            :time_series => Nightfury::Metric::TimeSeries,
            :avg_time_series => Nightfury::Metric::AvgTimeSeries
          }

      class << self
        
        attr_reader :metrics, :store_as

        def name
          self.to_s.demodulize.underscore
        end

        def metric(name, type = :value)
          @metrics ||= {}
          @metrics[name] = {type: type}
           
          class_eval <<-ENDOFMETHOD
            def #{name}
              @_#{name} ||= METRIC_MAPPINGS[:#{type}].new(:#{name}, redis_key_prefix: key_prefix)
            end
          ENDOFMETHOD
        end

      end
      
      attr_accessor :id

      def initialize(id)
        @id = id
      end

      def key_prefix
        store_name = self.class.store_as ? self.class.store_as : self.class.name
        "#{store_name}:#{id}"
      end
    end
  end
end
