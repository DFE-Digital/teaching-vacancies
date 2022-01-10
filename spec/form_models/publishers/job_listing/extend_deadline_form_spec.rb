require "rails_helper"

RSpec.describe Publishers::JobListing::ExtendDeadlineForm, type: :model do
  subject { described_class.new(params) }

  let(:expires_at) { 1.year.from_now }
  let(:previous_deadline) { 6.months.from_now }
  let(:starts_on) { 2.years.from_now }
  let(:starts_asap) { "0" }

  let(:params) do
    {
      "expires_at(1i)" => expires_at.year.to_s,
      "expires_at(2i)" => expires_at.month.to_s,
      "expires_at(3i)" => expires_at.day.to_s,
      expiry_time: "9:00",
      previous_deadline:,
      "starts_on(1i)" => starts_on.year.to_s,
      "starts_on(2i)" => starts_on.month.to_s,
      "starts_on(3i)" => starts_on.day.to_s,
      starts_asap:,
    }
  end

  context "when all attributes are valid" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end

  it { is_expected.to validate_inclusion_of(:expiry_time).in_array(Vacancy::EXPIRY_TIME_OPTIONS) }

  describe "expires_at" do
    context "when date is blank" do
      before do
        params["expires_at(1i)"] = ""
        params["expires_at(2i)"] = ""
        params["expires_at(3i)"] = ""
      end

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:expires_at, :blank)).to be true
      end
    end

    context "when date is incomplete" do
      before { params["expires_at(2i)"] = "" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:expires_at, :invalid)).to be true
      end
    end

    context "when date is invalid" do
      before { params["expires_at(2i)"] = "100" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:expires_at, :invalid)).to be true
      end
    end

    context "when date is not extended" do
      let(:expires_at) { 1.month.from_now }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:expires_at, :after)).to be true
      end
    end

    context "when date is not in the future" do
      let(:expires_at) { 1.month.ago }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:expires_at, :on_or_after)).to be true
      end
    end

    context "when date is too far in the future" do
      let(:expires_at) { 25.months.from_now }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:expires_at, :on_or_before)).to be true
      end
    end
  end

  describe "starts_on" do
    context "when date is incomplete" do
      before { params["starts_on(2i)"] = "" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:starts_on, :invalid)).to be true
      end
    end

    context "when date is invalid" do
      before { params["starts_on(2i)"] = "100" }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:starts_on, :invalid)).to be true
      end
    end

    context "when date is not in the future" do
      let(:starts_on) { 1.year.ago }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:starts_on, :on_or_after)).to be true
      end
    end

    context "when date is too far in the future" do
      let(:starts_on) { 25.months.from_now }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:starts_on, :on_or_before)).to be true
      end
    end

    context "when date is before expires_at" do
      let(:starts_on) { 9.months.from_now }

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:starts_on, :after)).to be true
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
