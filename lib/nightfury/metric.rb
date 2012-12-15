module Nightfury
  module Metric
    class Base      
      attr_reader :name
      
      def initialize(name)
        @name = name
      end
    end
  end
end
