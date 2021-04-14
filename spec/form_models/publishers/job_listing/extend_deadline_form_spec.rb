require "rails_helper"

RSpec.describe Publishers::JobListing::ExtendDeadlineForm, type: :model do
  subject { described_class.new(params) }

  let(:expires_on) { 1.year.from_now }
  let(:previous_deadline) { 6.months.from_now }
  let(:starts_on) { 2.years.from_now }
  let(:starts_asap) { "0" }

  let(:params) do
    {
      "expires_on(1i)" => expires_on.year.to_s,
      "expires_on(2i)" => expires_on.month.to_s,
      "expires_on(3i)" => expires_on.day.to_s,
      expiry_time: "9:00",
      previous_deadline: previous_deadline,
      "starts_on(1i)" => starts_on.year.to_s,
      "starts_on(2i)" => starts_on.month.to_s,
      "starts_on(3i)" => starts_on.day.to_s,
      starts_asap: starts_asap,
    }
  end

  context "when all attributes are valid" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end

  it { is_expected.to validate_inclusion_of(:expiry_time).in_array(%w[9:00 12:00 17:00 23:59]) }

  describe "expires_on" do
    it { is_expected.to validate_presence_of(:expires_on) }

    context "when date is incomplete" do
      before { params.delete("expires_on(2i)") }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:expires_on, :invalid)).to be true
      end
    end

    context "when date is invalid" do
      before { params["expires_on(2i)"] = "100" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:expires_on, :invalid)).to be true
      end
    end
  end

  describe "expires_at" do
    context "when date is not extended" do
      let(:expires_on) { 1.month.from_now }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:expires_on, :not_extended)).to be true
      end
    end

    context "when date is not in the future" do
      let(:expires_on) { 1.month.ago }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:expires_on, :in_past)).to be true
      end
    end
  end

  describe "starts_on" do
    context "when date is not in the future" do
      let(:starts_on) { 1.year.ago }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:starts_on, :in_past)).to be true
      end
    end

    context "when date is before expires_at" do
      let(:starts_on) { 9.months.from_now }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:starts_on, :before_deadline)).to be true
      end
    end

    context "when date and starts_asap are present" do
      let(:starts_asap) { "true" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:starts_on, :date_and_asap)).to be true
      end
    end
  end
end
