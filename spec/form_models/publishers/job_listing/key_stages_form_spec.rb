require "rails_helper"

RSpec.describe Publishers::JobListing::KeyStagesForm, type: :model do
  subject { described_class.new(params, vacancy) }

  let(:vacancy) { build_stubbed(:vacancy, phases: %w[secondary]) }
  let(:params) { { key_stages: key_stages } }

  context "when vacancy does not allow key stages" do
    before do
      allow(vacancy).to receive(:allow_key_stages?).and_return(false)
    end

    let(:key_stages) { %w[ks4 ks5] }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when key stages selected and key stages in allowed key stages" do
    before { allow(vacancy).to receive(:allow_key_stages?).and_return(true) }

    let(:key_stages) { %w[ks3 ks4] }

    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when key stages selected and key stages not in allowed key stages" do
    before { allow(vacancy).to receive(:allow_key_stages?).and_return(true) }

    let(:key_stages) { %w[ks1 ks5] }

    it "is invalid" do
      expect(subject).to be_invalid
      expect(subject.errors.of_kind?(:key_stages, :inclusion)).to be true
    end
  end

  context "when no key stages selected" do
    before { allow(vacancy).to receive(:allow_key_stages?).and_return(true) }

    let(:key_stages) { nil }

    it "is invalid" do
      expect(subject).to be_invalid
      expect(subject.errors.of_kind?(:key_stages, :inclusion)).to be true
    end
  end
end
