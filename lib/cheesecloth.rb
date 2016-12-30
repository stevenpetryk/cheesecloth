# frozen_string_literal: true
require "active_support"

require_relative "cheesecloth/version"
require_relative "cheesecloth/errors"
require_relative "cheesecloth/filter"
require_relative "cheesecloth/filter_list"
require_relative "cheesecloth/wrapper"

module CheeseCloth
  extend ActiveSupport::Concern

  included do
    cattr_accessor :cheesecloth_wrapper
    self.cheesecloth_wrapper = Wrapper.new(self)

    attr_accessor :scope_override
  end

  class_methods do
    def scope(*args)
      cheesecloth_wrapper.assign_default_scope_proc(*args)
    end

    def filter(conditions = nil, &block)
      cheesecloth_wrapper.filter_list.add_filter(conditions, block)
    end
  end

  def scope
    cheesecloth_instance_scope
  end

  def filtered_collection(scope: nil)
    self.scope_override = scope

    cheesecloth_wrapper.prepare
    raise MissingScopeError, self.class unless cheesecloth_instance_scope

    cheesecloth_wrapper.run(self)
  end

  private

  def cheesecloth_wrapper
    self.class.cheesecloth_wrapper
  end

  def cheesecloth_instance_scope
    scope_override || cheesecloth_wrapper.scope
  end
end
