module Nightfury
  module Identity
    class Base

      class << self
        
        attr_reader :metrics

        def name
          self.to_s.demodulize.underscore
        end

        def metric(name, type = :value)
          @metrics ||= {}
          @metrics[name] = {type: type}
          define_method(name) do
            unless instance_variable_get("@_#{name}")
              _metric = self.class.metric_mappings[type].new(name, redis_key_prefix: key_prefix)
              instance_variable_set("@_#{name}", _metric)
            end
            instance_variable_get("@_#{name}")
          end
        end

        def metric_mappings
          {
            :value => Nightfury::Metric::Value,
            :time_series => Nightfury::Metric::TimeSeries
          }
        end
      end
      
      attr_accessor :id

      def initialize(id)
        @id = id
      end

      def key_prefix
        "#{self.class.name}:#{id}"
      end
    end
  end
end
