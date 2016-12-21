require_relative "parameter_list"

# frozen_string_literal: true
module CheeseCloth
  class Wrapper
    attr_reader :klass, :parameter_list, :scope, :scope_proc

    def initialize(klass)
      @klass = klass
      @parameter_list = ParameterList.new
    end

    def assign_scope(block)
      @scope_proc = block
    end

    def add_parameter_proxy(name, type)
      parameter_list.add_parameter_proxy(name, type)
    end

    def ready(params)
      @scope = scope_proc && scope_proc.call

      parameter_list.ready(klass, params)
    end
  end
end
