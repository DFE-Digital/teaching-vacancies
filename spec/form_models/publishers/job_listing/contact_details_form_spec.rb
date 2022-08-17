require "rails_helper"

RSpec.describe Publishers::JobListing::ContactDetailsForm, type: :model do
  subject { described_class.new(params, vacancy, current_publisher) }

  let(:vacancy) { build_stubbed(:vacancy) }
  let(:current_publisher) { build_stubbed(:publisher, email: "test@example.com") }
  let(:params) { {} }

  describe "contact number provided" do
    it { is_expected.to validate_inclusion_of(:contact_number_provided).in_array([true, false, "true", "false"]) }
  end

  describe "contact number" do
    context "when contact_number_provided is false" do
      before { allow(subject).to receive(:contact_number_provided).and_return("false") }
      it { is_expected.not_to validate_presence_of(:contact_number) }
    end

    context "when contact_number_provided is true" do
      before { allow(subject).to receive(:contact_number_provided).and_return("true") }
      it { is_expected.to validate_presence_of(:contact_number) }
    end
  end

  describe "contact email" do
    before { allow(subject).to receive(:contact_number_provided).and_return("false") }

    context "when contact_email is current publisher email" do
      let(:params) { { other_contact_email: nil, contact_email: current_publisher.email } }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when contact_email is other email and other_contact_email not nil" do
      let(:params) { { other_contact_email: "test2@example.com", contact_email: "other" } }

      it "is valid" do
        expect(subject).to be_valid
      end

      it "saves the correct email" do
        expect(subject.params_to_save[:contact_email]).to eq(params[:other_contact_email])
      end
    end

    context "when contact_email is other email and other_contact_email nil" do
      let(:params) { { other_contact_email: nil, contact_email: "other" } }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:other_contact_email, :blank)).to be true
      end
    end

    context "when contact_email is other and other_contact_email blank" do
      let(:params) { { other_contact_email: "", contact_email: "other" } }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:other_contact_email, :blank)).to be true
      end
    end

    context "when contact_email is other and other_contact_email valid" do
      let(:params) { { other_contact_email: "test2@example.com", contact_email: current_publisher.email } }

      it "is valid" do
        expect(subject).to be_valid
      end

      it "saves the correct email" do
        expect(subject.params_to_save[:contact_email]).to eq(current_publisher.email)
      end
    end
  end
end
