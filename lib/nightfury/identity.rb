module Nightfury
  module Identity
    class Base

      METRIC_MAPPINGS = {
            :value => Nightfury::Metric::Value,
            :time_series => Nightfury::Metric::TimeSeries,
            :avg_time_series => Nightfury::Metric::AvgTimeSeries,
            :count_time_series => Nightfury::Metric::CountTimeSeries
          }

      class << self
        
        attr_reader :metrics, :tags
        attr_accessor :store_as

        def name
          self.to_s.demodulize.underscore
        end

        def metric(name, type = :value, options={})
          @metrics ||= {}
          @metrics[name] = {type: type}
          store_as = options[:store_as] ? ":#{options[:store_as]}" : 'nil' 
          class_eval <<-ENDOFMETHOD
            def #{name}
              @_#{name} ||= METRIC_MAPPINGS[:#{type}].new(:#{name}, redis_key_prefix: key_prefix, store_as: #{store_as})
            end
          ENDOFMETHOD
        end
        
        def tag(name, options={})
          @tags ||= {}
          @tags[name] = options[:store_as] ? options[:store_as] : name
        end
      end
      
      attr_accessor :id, :tags
      attr_reader :redis

      def initialize(id, options={})
        @redis = Nightfury.redis
        @id = id
        @tags = options[:tags]
      end

      def key_prefix
        store_name = self.class.store_as ? self.class.store_as : self.class.name
        tag_ids = generate_tag_ids
        tag_ids = tag_ids.nil? ? '' : ":#{tag_ids}"
        "#{store_name}.#{id}#{tag_ids}"
      end

      def new_record?
        redis.keys("#{key_prefix}*").empty?
      end

      private 

      def generate_tag_ids
        return nil unless tags
        tag_values = {}
        tags.each do |key, value|
          store_name = self.class.tags[key]
          next if store_name.nil?
          tag_values[store_name] = value
        end

        tag_ids = nil
        tag_values_sorted = tag_values.keys.sort
        tag_values_sorted.each do |store_name|
          tag = "#{store_name}.#{tag_values[store_name]}"
          if tag_ids.nil?
            tag_ids = tag
          else
            tag_ids = "#{tag_ids}:#{tag}"
          end
        end

        tag_ids
      end
    end
  end
end
