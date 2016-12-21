# frozen_string_literal: true
require "spec_helper"

describe "CheeseCloth::Params" do
  let(:dummy_class) do
    Class.new do
      include CheeseCloth

      scope -> { [1, 2, 3] }
    end
  end

  describe ".param" do
    before do
      dummy_class.param :boolean, :boolean
      dummy_class.param :datetime, :datetime
    end

    it "correctly casts a boolean" do
      expect(dummy_class.new(boolean: "true").boolean).to eq true
    end

    it "correctly casts a datetime" do
      expect(dummy_class.new(datetime: "2016-10-10").datetime).to eq DateTime.parse("2016-10-10")
    end
  end
end
