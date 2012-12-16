module Nightfury
  module Metric
    class Base      
      attr_reader :name, :redis, :redis_key_prefix
      
      def initialize(name, options={})
        @name = name
        @redis = Nightfury.redis
        @redis_key_prefix = options[:redis_key_prefix]
      end

      def redis_key
        prefix = redis_key_prefix.blank? ? '' : "#{redis_key_prefix}:"
        "#{prefix}metric:#{name}" 
      end
    end
  end
end


