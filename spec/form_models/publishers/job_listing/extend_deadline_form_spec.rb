require "rails_helper"

RSpec.describe Publishers::JobListing::ExtendDeadlineForm, type: :model do
  subject { described_class.new(params) }

  let(:expires_at) { 1.year.from_now }
  let(:previous_deadline) { 6.months.from_now }
  let(:start_date_type) { "specific_date" }
  let(:starts_on) { 2.years.from_now }
  let(:earliest_start_date) { 18.months.from_now }
  let(:latest_start_date) { 19.months.from_now }
  let(:other_start_date_details) { nil }
  let(:extension_reason) { "no_applications" }

  let(:params) do
    {
      "expires_at(1i)" => expires_at.year.to_s,
      "expires_at(2i)" => expires_at.month.to_s,
      "expires_at(3i)" => expires_at.day.to_s,
      expiry_time: "9:00",
      previous_deadline: previous_deadline,
      start_date_type: start_date_type,
      "starts_on(1i)" => starts_on.year.to_s,
      "starts_on(2i)" => starts_on.month.to_s,
      "starts_on(3i)" => starts_on.day.to_s,
      "earliest_start_date(1i)" => earliest_start_date.year.to_s,
      "earliest_start_date(2i)" => earliest_start_date.month.to_s,
      "earliest_start_date(3i)" => earliest_start_date.day.to_s,
      "latest_start_date(1i)" => latest_start_date.year.to_s,
      "latest_start_date(2i)" => latest_start_date.month.to_s,
      "latest_start_date(3i)" => latest_start_date.day.to_s,
      other_start_date_details: other_start_date_details,
      extension_reason: extension_reason,
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

  describe "start_date_type" do
    context "when blank" do
      let(:start_date_type) { nil }
      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:start_date_type, :inclusion)).to be true
      end
    end
  end

  describe "starts_on" do
    context "when date is incomplete" do
      before { params["starts_on(2i)"] = "" }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:starts_on, :invalid)).to be true
      end
    end

    context "when date is invalid" do
      before { params["starts_on(2i)"] = "100" }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:starts_on, :invalid)).to be true
      end
    end

    context "when date is not in the future" do
      let(:starts_on) { 1.year.ago }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:starts_on, :on_or_after)).to be true
      end
    end

    context "when date is too far in the future" do
      let(:starts_on) { 25.months.from_now }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:starts_on, :on_or_before)).to be true
      end
    end

    context "when date is before expires_at" do
      let(:starts_on) { 9.months.from_now }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:starts_on, :after)).to be true
      end
    end
  end

  describe "earliest_start_date" do
    let(:start_date_type) { "date_range" }

    context "when date is incomplete" do
      before { params["earliest_start_date(2i)"] = "" }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:earliest_start_date, :invalid)).to be true
      end
    end

    context "when date is invalid" do
      before { params["earliest_start_date(2i)"] = "100" }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:earliest_start_date, :invalid)).to be true
      end
    end

    context "when date is not in the future" do
      let(:earliest_start_date) { 1.year.ago }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:earliest_start_date, :on_or_after)).to be true
      end
    end

    context "when date is too far in the future" do
      let(:earliest_start_date) { 25.months.from_now }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:earliest_start_date, :on_or_before)).to be true
      end
    end

    context "when date is before expires_at" do
      let(:earliest_start_date) { 9.months.from_now }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:earliest_start_date, :after)).to be true
      end
    end

    context "when date is after latest_start_date" do
      let(:earliest_start_date) { latest_start_date + 1.month }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:earliest_start_date, :before)).to be true
      end
    end
  end

  describe "latest_start_date" do
    let(:start_date_type) { "date_range" }

    context "when date is incomplete" do
      before { params["latest_start_date(2i)"] = "" }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:latest_start_date, :invalid)).to be true
      end
    end

    context "when date is invalid" do
      before { params["latest_start_date(2i)"] = "100" }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:latest_start_date, :invalid)).to be true
      end
    end

    context "when date is not in the future" do
      let(:latest_start_date) { 1.year.ago }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:latest_start_date, :on_or_after)).to be true
      end
    end

    context "when date is too far in the future" do
      let(:latest_start_date) { 25.months.from_now }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:latest_start_date, :on_or_before)).to be true
      end
    end

    context "when date is before expires_at" do
      let(:latest_start_date) { 9.months.from_now }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:latest_start_date, :after)).to be true
      end
    end

    context "when date is before earliest_start_date" do
      let(:latest_start_date) { earliest_start_date - 1.month }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:latest_start_date, :after)).to be true
      end
    end
  end

  describe "other_start_date_details" do
    let(:start_date_type) { "other" }

    context "when blank" do
      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:other_start_date_details, :blank)).to be true
      end
    end

    context "when not blank" do
      let(:other_start_date_details) { "test" }

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
