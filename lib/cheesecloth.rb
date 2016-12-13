# frozen_string_literal: true
require "active_support"

require "cheesecloth/version"
require "cheesecloth/base_scope"

module CheeseCloth
  extend ActiveSupport::Concern

  include BaseScope

  def initialize(scope: self.class.base_scope)
    @scope = scope
  end
end
