# frozen_string_literal: true
module CheeseCloth
  module Params
    class BaseParamProxy
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def normalized
        value
      end
    end
  end
end
