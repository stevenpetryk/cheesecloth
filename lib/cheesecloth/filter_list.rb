# frozen_string_literal: true
module CheeseCloth
  class FilterList
    attr_reader :instance, :filters

    def initialize(instance)
      @instance = instance
      @filters = []
    end

    def add_filter(conditions, block)
      @filters << Filter.new(conditions, block)
    end

    def run_filters(instance)
      runnable_filters_on(instance).each do |filter|
        instance.scope = filter.run(instance)
      end
    end

    private

    def runnable_filters_on(instance)
      filters.select { |filter| filter.conditions_satisfied?(instance) }
    end
  end
end
