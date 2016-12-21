# frozen_string_literal: true
module CheeseCloth
  module Params
    class DatetimeParamProxy < BaseParamProxy
      def normalized
        DateTime.parse(value)
      rescue ArgumentError
        nil
      end
    end
  end
end
