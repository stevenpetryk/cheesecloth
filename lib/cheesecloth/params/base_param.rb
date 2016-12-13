# frozen_string_literal: true
module CheeseCloth
  module Params
    class BaseParam
      def initialize(value)
        @value = value
      end

      def normalized
        @value
      end
    end
  end
end
