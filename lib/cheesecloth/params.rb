# frozen_string_literal: true
require "cheesecloth/params/base_param_proxy"
require "cheesecloth/params/boolean_param_proxy"
require "cheesecloth/params/datetime_param_proxy"

module CheeseCloth
  module Params
    extend ActiveSupport::Concern

    # TODO: Add more of these.
    TYPE_MAPPINGS = {
      boolean: BooleanParamProxy,
      datetime: DatetimeParamProxy,
    }.freeze

    included do
      cattr_accessor :proxy_classes
      self.proxy_classes = {}
    end

    private

    def instantiate_proxies
      @proxies ||= {}

      self.class.proxy_classes.each do |name, proxy|
        @proxies[name] = proxy.new(params[name] || params[name.to_sym])
      end
    end

    def method_missing(symbol, *args)
      super unless respond_to_missing?(symbol)

      @proxies[symbol].normalized
    end

    def respond_to_missing?(symbol)
      @proxies[symbol].is_a? BaseParamProxy
    end

    class_methods do
      def param(name, type)
        proxy_classes[name.to_sym] = proxy_for_type(type)
      end

      def proxy_for_type(type)
        if type.is_a? BaseParamProxy
          type
        else
          TYPE_MAPPINGS[type.to_sym]
        end
      end
    end
  end
end
