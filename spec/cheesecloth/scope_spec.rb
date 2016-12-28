# frozen_string_literal: true
require "spec_helper"

describe "CheeseCloth.scope" do
  let(:dummy_class) do
    Class.new { include CheeseCloth }
  end

  describe ".scope" do
    before do
      dummy_class.scope -> { [1, 2, 3] }
    end

    it "sets the base collection" do
      expect(dummy_class.new.filtered_collection).to eq [1, 2, 3]
    end

    it "can be overriden dynamically during initialization" do
      expect(dummy_class.new(scope: [3, 2, 1]).filtered_collection).to eq [3, 2, 1]
    end
  end

  describe "error handling" do
    context "when the base scope isn't set" do
      it "throws an exception" do
        expect { dummy_class.new.filtered_collection }.
          to raise_error(CheeseCloth::MissingScopeError)
      end
    end
  end
end
