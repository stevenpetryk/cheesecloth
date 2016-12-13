# frozen_string_literal: true
require "spec_helper"

describe CheeseCloth::Params do
  let(:dummy_class) do
    klass = Class.new { include CheeseCloth }
    klass.instance_eval(&extensions)
    klass
  end

  describe ".param" do
    let(:extensions) do
      Proc.new do
        scope -> { [1, 2, 3] }

        param :boolean, :boolean
        param :datetime, :datetime
      end
    end

    it "correctly casts a boolean" do
      expect(dummy_class.new(boolean: "true").boolean).to eq true
    end

    it "correctly casts a datetime" do
      expect(dummy_class.new(datetime: "2016-10-10").datetime).to eq Time.parse("2016-10-10")
    end
  end
end
