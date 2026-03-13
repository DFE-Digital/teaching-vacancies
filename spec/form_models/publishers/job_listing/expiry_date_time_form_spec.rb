require "rails_helper"

RSpec.describe Publishers::JobListing::ExpiryDateTimeForm, type: :model do
  let(:form) { described_class.new(params) }

  let(:vacancy) { build_stubbed(:vacancy, publish_on: publish_on) }

  let(:publish_on_day) { "another_day" }
  let(:publish_on) { 6.months.from_now }
  let(:expires_at) { 1.year.from_now }

  let(:params) do
    {
      publish_on: publish_on,
      "expires_at(1i)" => expires_at.year.to_s,
      "expires_at(2i)" => expires_at.month.to_s,
      "expires_at(3i)" => expires_at.day.to_s,
      expiry_time: "9:00",
    }
  end

  context "when all attributes are valid" do
    it "is valid" do
      expect(form).to be_valid
    end
  end

  describe "validations" do
    subject { form }

    it { is_expected.to validate_inclusion_of(:expiry_time).in_array(Vacancy::EXPIRY_TIME_OPTIONS) }
  end

  describe "expires_at" do
    context "when date is blank" do
      before do
        params["expires_at(1i)"] = ""
        params["expires_at(2i)"] = ""
        params["expires_at(3i)"] = ""
      end

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:expires_at, :blank)).to be true
      end
    end

    context "when date is incomplete" do
      before { params["expires_at(2i)"] = "" }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:expires_at, :invalid)).to be true
      end
    end

    context "when date is invalid" do
      before { params["expires_at(2i)"] = "100" }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:expires_at, :invalid)).to be true
      end
    end

    context "when date is not in the future" do
      let(:expires_at) { 1.month.ago }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:expires_at, :on_or_after)).to be true
      end
    end

    context "when date is too far in the future" do
      let(:expires_at) { 25.months.from_now }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:expires_at, :on_or_before)).to be true
      end
    end

    context "when date is before publish_on" do
      let(:expires_at) { 3.months.from_now }

      it "is invalid" do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:expires_at, :after)).to be true
      end
    end
  end
end
