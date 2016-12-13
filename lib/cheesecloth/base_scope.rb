# frozen_string_literal: true
module CheeseCloth
  module BaseScope
    extend ActiveSupport::Concern

    included do
      cattr_accessor :base_scope
    end

    def filtered_collection
      @scope
    end

    class_methods do
      def scope(block)
        self.base_scope = block.call
      end
    end
  end
end
