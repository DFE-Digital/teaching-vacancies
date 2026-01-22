require "rails_helper"

RSpec.describe Publishers::JobListing::ConfirmContactDetailsForm, type: :model do
  subject(:form) { described_class.new(params, vacancy) }

  let(:vacancy) { build_stubbed(:vacancy) }
  let(:params) { {} }

  describe "confirm_contact_email" do
    context "when contact_email does not belong to a registered publisher" do
      before do
        allow(vacancy).to receive(:contact_email_belongs_to_a_publisher?).and_return(false)
      end

      context "when confirm_contact_email is present" do
        let(:params) { { confirm_contact_email: "true" } }

        it "is valid" do
          expect(form).to be_valid
        end
      end

      context "when confirm_contact_email is nil" do
        let(:params) { { confirm_contact_email: nil } }

        it "is invalid" do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(:confirm_contact_email, :blank)).to be true
        end
      end
    end

    context "when contact_email belongs to a registered publisher" do
      before do
        allow(vacancy).to receive(:contact_email_belongs_to_a_publisher?).and_return(true)
      end

      let(:params) { { confirm_contact_email: nil } }

      it "is valid" do
        expect(form).to be_valid
      end
    end
  end

  describe ".fields" do
    it "returns the confirm_contact_email" do
      expect(described_class.fields).to eq(%i[confirm_contact_email])
    end
  end

  describe ".load_from_model" do
    context "when the step is recorded as completed" do
      before do
        allow(vacancy).to receive(:completed_steps).and_return(%w[confirm_contact_details])
      end

      it "loads confirm_contact_email as true" do
        loaded_params = described_class.load_from_model(vacancy, current_publisher: nil)
        expect(loaded_params.confirm_contact_email).to be true
      end
    end

    context "when the step is not recorded as completed" do
      before do
        allow(vacancy).to receive(:completed_steps).and_return([])
      end

      it "loads an empty hash" do
        loaded_params = described_class.load_from_model(vacancy, current_publisher: nil)
        expect(loaded_params.confirm_contact_email).to be_nil
      end
    end
  end
end
