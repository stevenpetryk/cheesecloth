# frozen_string_literal: true
module CheeseCloth
  module ParameterProxies
    class BaseParameterProxy
      attr_reader :name, :value

      def initialize(name, value)
        @name = name
        @value = value
      end

      def normalized
        value
      end

      def method_names
        [name]
      end
    end
  end
end
