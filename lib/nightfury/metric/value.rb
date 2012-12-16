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

      def incr(step=1)
        redis.incrby(redis_key, step)
      end
    
      def decr(step=1)
        redis.decrby(redis_key, step)
      end

      private

      def before_set(value)
        value
      end
    end
  end
end
