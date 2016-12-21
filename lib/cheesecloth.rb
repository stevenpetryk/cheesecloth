# frozen_string_literal: true
require "active_support/concern"
require "active_support/core_ext/class/attribute_accessors"
require "active_support/core_ext/string/strip"
require "active_support/core_ext/module/delegation"

require "cheesecloth/version"
require "cheesecloth/errors"
require "cheesecloth/wrapper"

module CheeseCloth
  extend ActiveSupport::Concern

  included do
    cattr_accessor :cheesecloth_wrapper
    self.cheesecloth_wrapper = Wrapper.new(self)

    attr_reader :scope, :params
  end

  class_methods do
    def scope(*args)
      cheesecloth_wrapper.assign_scope(*args)
    end

    def param(*args)
      cheesecloth_wrapper.add_parameter_proxy(*args)
    end
  end

  def initialize(params, scope: nil)
    cheesecloth_wrapper.ready(params)

    @params = params
    @scope = scope || cheesecloth_wrapper.scope

    raise MissingScopeError, self.class unless @scope
  end

  def filtered_collection
    @scope
  end

  private

  def cheesecloth_wrapper
    self.class.cheesecloth_wrapper
  end
end
