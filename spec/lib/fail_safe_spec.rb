require "rails_helper"

RSpec.describe Kernel do
  context "when the block raises an error" do
    subject do
      fail_safe(42) do
        raise "But the plans were on display..."
      end
    end

    context "when not in production" do
      it "does not capture errors occurring in the block" do
        expect { subject }.to raise_error(RuntimeError, "But the plans were on display...")
      end
    end

    context "when in production" do
      before do
        allow(Rails.env).to receive(:production?).and_return(true)
      end

      it "hides errors raised in the block" do
        expect { subject }.not_to raise_error
      end

      it "notifies Rollbar of errors raised in the block" do
        expect(Rollbar).to receive(:error).with(an_instance_of(RuntimeError))
        subject
      end

      it "returns the default value" do
        expect(subject).to eq(42)
      end
    end
  end

  context "when the block does not raise an error" do
    subject do
      fail_safe(42) do
        "A. Dent"
      end
    end

    it "returns the block's return value" do
      expect(subject).to eq("A. Dent")
    end
  end
end
