# frozen_string_literal: true
require "spec_helper"

describe "CheeseCloth.attribute" do
  let(:dummy_class) do
    Class.new do
      include CheeseCloth

      scope -> { [1, 2, 3] }
    end
  end

  describe ".attribute" do
    before do
      dummy_class.attribute :name, String
    end

    it "delegates attributes to Virtus" do
      expect(dummy_class.new(name: "Bob").name).to eq "Bob"
    end
  end
end
