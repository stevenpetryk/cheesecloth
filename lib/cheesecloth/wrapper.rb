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

    def prepare_and_run(instance)
      assign_and_check_scope(instance)
      run(instance)
    end

    def assign_and_check_scope(instance)
      @scope = default_scope_proc && instance.instance_exec(&default_scope_proc)
      raise MissingScopeError, self.class unless instance.scope
    end

    def run(instance)
      filter_list.run_filters(instance)
    end
  end
end
