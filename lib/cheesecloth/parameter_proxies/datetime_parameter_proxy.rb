# frozen_string_literal: true
module CheeseCloth
  module ParameterProxies
    class DatetimeParameterProxy < BaseParameterProxy
      def normalized
        DateTime.parse(value)
      rescue ArgumentError
        nil
      end
    end
  end
end
