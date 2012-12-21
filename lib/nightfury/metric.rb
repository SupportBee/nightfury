module Nightfury
  module Metric
    class Base      
      attr_reader :name, :redis, :redis_key_prefix, :store_as
      
      def initialize(name, options={})
        @name = name
        @redis = Nightfury.redis
        @redis_key_prefix = options[:redis_key_prefix]
        @store_as = options[:store_as]
      end

      def redis_key
        prefix = redis_key_prefix.blank? ? '' : "#{redis_key_prefix}:"
        store_name = store_as ? store_as : name
        "#{prefix}#{store_name}" 
      end

      def delete
        redis.del redis_key
      end
    end
  end
end


