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
      filters.each { |filter| filter.run(instance) }
    end
  end
end
