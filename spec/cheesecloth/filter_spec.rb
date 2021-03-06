# frozen_string_literal: true
require "spec_helper"

describe "CheeseCloth.filter" do
  let(:starting_scope) { [1, 2, 3] }

  let(:dummy_class) do
    klass = Class.new do
      cattr_accessor :starting_scope

      include CheeseCloth

      def some_present_param
        true
      end

      def some_blank_param
        nil
      end
    end
    klass.starting_scope = starting_scope
    klass.scope -> { starting_scope }
    klass
  end

  context "when filtering on a present param" do
    before do
      dummy_class.filter(:some_present_param) do
        scope.reverse
      end
    end

    it "runs the filter" do
      expect(dummy_class.new.filtered_scope).to eq starting_scope.reverse
    end
  end

  context "when filtering on a non-present param" do
    before do
      dummy_class.filter(:some_blank_param) do
        scope.reverse
      end
    end

    it "does not run the filter" do
      expect(dummy_class.new.filtered_scope).to eq starting_scope
    end
  end

  context "when always running the filter" do
    before do
      dummy_class.filter do
        scope.reverse
      end
    end

    it "runs the filter" do
      expect(dummy_class.new.filtered_scope).to eq starting_scope.reverse
    end
  end

  context "when filtering multiple times" do
    before do
      dummy_class.filter do
        scope.reverse
      end

      dummy_class.filter do
        scope.reverse
      end
    end

    it "chains the filters" do
      expect(dummy_class.new.filtered_scope).to eq starting_scope
    end
  end

  context "when filtering on multiple params" do
    context "when one is false" do
      before do
        dummy_class.filter [:some_present_param, :some_blank_param] do
          scope.reverse
        end
      end

      it "does not run the filter" do
        expect(dummy_class.new.filtered_scope).to eq starting_scope
      end
    end

    context "when both are true" do
      before do
        dummy_class.filter [:some_present_param, :some_present_param] do
          scope.reverse
        end
      end

      it "runs the filter" do
        expect(dummy_class.new.filtered_scope).to eq starting_scope.reverse
      end
    end
  end
end
