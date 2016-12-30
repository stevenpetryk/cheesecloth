# frozen_string_literal: true
module CheeseCloth
  class Wrapper
    attr_reader :klass, :filter_list, :scope, :default_scope_proc

    def initialize(klass)
      @klass = klass
      @filter_list = FilterList.new(klass)
    end

    def assign_default_scope_proc(block)
      @default_scope_proc = block
    end

    def ready(instance)
      @scope ||= default_scope_proc && default_scope_proc.call
      filter_list.run_filters(instance)
    end
  end
end
