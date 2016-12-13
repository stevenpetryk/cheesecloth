# frozen_string_literal: true
require "active_support/concern"
require "active_support/core_ext/class/attribute_accessors"
require "active_support/core_ext/string/strip"

require "cheesecloth/version"
require "cheesecloth/base_scope"
require "cheesecloth/errors"
require "cheesecloth/params"

module CheeseCloth
  extend ActiveSupport::Concern

  include BaseScope
  include Params

  attr_reader :params, :scope

  def initialize(params, scope: self.class.base_scope_proc&.call)
    raise MissingScopeError, self.class unless scope

    @params = params
    @scope = scope
  end
end
