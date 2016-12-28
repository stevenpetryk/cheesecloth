# frozen_string_literal: true
module CheeseCloth
  class Wrapper
    attr_reader :klass, :parameter_list, :scope, :default_scope_proc

    def initialize(klass)
      @klass = klass
    end

    def assign_default_scope_proc(block)
      @default_scope_proc = block
    end

    def ready
      return if @ready
      @ready = true

      @scope = default_scope_proc && default_scope_proc.call
    end
  end
end
