module Nightfury
  module Metric
    class Value < Base
      def set(value)
        value = before_set(value)
        redis.set(redis_key, value)
      end

      def get
        redis.get(redis_key)
      end

      def incr
        redis.incr(redis_key)
      end
    
      def decr
        redis.decr(redis_key)
      end

      private

      def before_set(value)
        value
      end
    end
  end
end
