# frozen_string_literal: true

require_relative "parameter_proxies/base_parameter_proxy"
require_relative "parameter_proxies/boolean_parameter_proxy"
require_relative "parameter_proxies/datetime_parameter_proxy"

module CheeseCloth
  class ParameterList
    attr_accessor :parameter_proxy_classes, :parameter_proxies

    TYPE_MAPPINGS = {
      boolean: ParameterProxies::BooleanParameterProxy,
      datetime: ParameterProxies::DatetimeParameterProxy,
    }.freeze

    def initialize
      @parameter_proxy_classes = {}
      @parameter_proxies = []
    end

    def add_parameter_proxy(name, type_descriptor)
      parameter_proxy_classes[name] = decode_type_descriptor(type_descriptor)
    end

    def ready(klass, params)
      parameter_proxy_classes.each do |name, proxy_class|
        parameter_proxies << proxy_class.new(name, params[name])
      end

      attach_accessors_to(klass)
    end

    private

    def attach_accessors_to(klass)
      parameter_proxies.each do |proxy|
        proxy.method_names.each do |method_name|
          attach_accessor(klass, proxy, method_name)
        end
      end
    end

    def attach_accessor(klass, proxy, method_name)
      klass.instance_eval do
        define_method method_name do
          proxy.normalized
        end
      end
    end

    def decode_type_descriptor(type_descriptor)
      TYPE_MAPPINGS[type_descriptor] || type_descriptor
    end
  end
end
