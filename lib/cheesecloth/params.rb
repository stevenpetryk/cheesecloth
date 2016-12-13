# frozen_string_literal: true
require "cheesecloth/params/base_param"
require "cheesecloth/params/boolean_param"
require "cheesecloth/params/datetime_param"

module CheeseCloth
  module Params
    extend ActiveSupport::Concern

    # TODO: Add more of these.
    TYPE_MAPPINGS = {
      boolean: BooleanParam,
      datetime: DatetimeParam,
    }.freeze

    class_methods do
      def param_for_type(type)
        return TYPE_MAPPINGS[type.to_sym] if type.respond_to? :to_sym
        type
      end

      def param(name, type)
        define_method(name) do
          self.class.param_for_type(type).
            new(params[name]).
            normalized
        end
      end
    end
  end
end
