# frozen_string_literal: true
require "active_support"

require_relative "cheesecloth/version"
require_relative "cheesecloth/errors"
require_relative "cheesecloth/wrapper"

module CheeseCloth
  extend ActiveSupport::Concern

  included do
    cattr_accessor :cheesecloth_wrapper
    self.cheesecloth_wrapper = Wrapper.new(self)

    attr_accessor :scope
  end

  class_methods do
    def scope(*args)
      cheesecloth_wrapper.assign_default_scope_proc(*args)
    end
  end

  def filtered_collection(scope: nil)
    self.scope = scope
    cheesecloth_wrapper.ready
    raise MissingScopeError, self.class unless cheesecloth_instance_scope

    cheesecloth_instance_scope
  end

  private

  def cheesecloth_wrapper
    self.class.cheesecloth_wrapper
  end

  def cheesecloth_instance_scope
    scope || cheesecloth_wrapper.scope
  end
end
