# frozen_string_literal: true
module CheeseCloth
  class Filter
    attr_reader :klass, :conditions, :block

    def initialize(conditions, block)
      @conditions = wrap(conditions)
      @block = block
    end

    def run(instance)
      return unless conditions_satisfied?(instance)

      instance.instance_eval(&block)
    end

    private

    def conditions_satisfied?(instance)
      return true if conditions.empty?

      conditions.all? { |condition| instance.send(condition).present? }
    end

    def wrap(possible_array)
      return [] if possible_array.nil?
      return possible_array if possible_array.is_a? Array

      [possible_array]
    end
  end
end
