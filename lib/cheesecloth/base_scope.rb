# frozen_string_literal: true
module CheeseCloth
  module BaseScope
    extend ActiveSupport::Concern

    included do
      cattr_accessor :base_scope_proc
    end

    class_methods do
      def scope(block)
        self.base_scope_proc = block
      end
    end
  end
end
