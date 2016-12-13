# frozen_string_literal: true
require "spec_helper"

describe CheeseCloth do
  it "can be successfully included" do
    expect do
      class Foo
        include CheeseCloth
      end
    end.to_not raise_error
  end
end
