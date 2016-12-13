# frozen_string_literal: true
module CheeseCloth
  module Params
    class DatetimeParam < BaseParam
      def normalized
        Time.parse(@value || "")
      end
    end
  end
end
