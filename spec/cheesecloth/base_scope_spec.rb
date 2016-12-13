# frozen_string_literal: true
require "spec_helper"

describe CheeseCloth::BaseScope do
  let(:dummy_class) do
    klass = Class.new { include CheeseCloth }
    klass.instance_eval(&extensions)
    klass
  end

  describe ".scope" do
    let(:extensions) do
      Proc.new do
        scope -> { [1, 2, 3] }
      end
    end

    it "sets the base collection" do
      expect(dummy_class.new.filtered_collection).to eq [1, 2, 3]
    end

    it "can be overriden dynamically during initialization" do
      expect(dummy_class.new(scope: [3, 2, 1]).filtered_collection).to eq [3, 2, 1]
    end
  end
end
