# frozen_string_literal: true
module CheeseCloth
  module Params
    class BooleanParamProxy < BaseParamProxy
      def normalized
        !["false", "f", "0", ""].include?(value)
      end
    end
  end
end
