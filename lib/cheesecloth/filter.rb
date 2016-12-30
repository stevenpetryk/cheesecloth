# frozen_string_literal: true
module CheeseCloth
  class Filter
    attr_reader :klass, :conditions, :block

    def initialize(conditions, block)
      @conditions = wrap(conditions)
      @block = block
    end

    def run(instance)
      instance.instance_eval(&block)
    end

    def conditions_satisfied?(instance)
      conditions.all? { |condition| instance.send(condition) }
    end

    private

    def wrap(possible_array)
      [possible_array].flatten.compact
    end
  end
end
