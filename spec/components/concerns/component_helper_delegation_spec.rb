require "rails_helper"

RSpec.describe ComponentHelperDelegation do
  let(:dummy_class) do
    Class.new do
      include ComponentHelperDelegation

      attr_accessor :view_context, :helpers
    end
  end

  let(:component) { dummy_class.new }
  # rubocop:disable RSpec/VerifiedDoubles
  let(:mock_helpers) { double("Helpers") }

  before do
    component.helpers = mock_helpers
    component.view_context = double("ViewContext")
  end
  # rubocop:enable RSpec/VerifiedDoubles

  describe "#method_missing" do
    context "when view_context is nil (initialization phase)" do
      before { component.view_context = nil }

      it "calls super directly without checking helpers" do
        expect(mock_helpers).not_to receive(:respond_to?)

        expect { component.test_helper_method }.to raise_error(NoMethodError)
      end
    end

    context "when the helper responds to the method" do
      before do
        allow(mock_helpers).to receive(:respond_to?).with(:test_helper_method).and_return(true)
        allow(mock_helpers).to receive(:public_send).with(:test_helper_method, "arg").and_return("success")
      end

      it "delegates the call to the helper" do
        expect(component.test_helper_method("arg")).to eq("success")
      end
    end

    context "when the helper does NOT respond to the method" do
      before do
        allow(mock_helpers).to receive(:respond_to?).with(:missing_method).and_return(false)
      end

      it "calls super and raises NoMethodError" do
        expect { component.missing_method }.to raise_error(NoMethodError)
      end
    end
  end

  describe "#respond_to?" do
    context "when view_context is nil" do
      before { component.view_context = nil }

      it "returns false (falling back to super)" do
        expect(component.respond_to?(:test_helper_method)).to be false
      end
    end

    context "when the helper has the method" do
      before do
        allow(mock_helpers).to receive(:respond_to?).with(:test_helper_method, false).and_return(true)
      end

      it "returns true" do
        expect(component.respond_to?(:test_helper_method)).to be true
      end
    end

    context "when the helper does not have the method" do
      before do
        allow(mock_helpers).to receive(:respond_to?).with(:missing_method, false).and_return(false)
      end

      it "returns false" do
        expect(component.respond_to?(:missing_method)).to be false
      end
    end
  end
end
