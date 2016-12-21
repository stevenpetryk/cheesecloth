# frozen_string_literal: true
module CheeseCloth
  module ParameterProxies
    class BooleanParameterProxy < BaseParameterProxy
      def normalized
        !["false", "f", "0", ""].include?(value)
      end

      def method_names
        super + ["#{name}?"]
      end
    end
  end
end
