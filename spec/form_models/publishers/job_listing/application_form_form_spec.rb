require "rails_helper"

RSpec.describe Publishers::JobListing::ApplicationFormForm, type: :model do
  subject { described_class.new(params, vacancy, current_publisher) }

  let(:vacancy) { build_stubbed(:vacancy, application_form: application_form) }
  let(:current_publisher) { build_stubbed(:publisher, email: "test@example.com") }

  describe "application email" do
    let(:application_form) { fixture_file_upload("blank_job_spec.pdf") }

    context "when application email is current publisher email" do
      let(:params) { { other_application_email: nil, application_email: current_publisher.email } }

      it "is valid" do
        expect(subject).to be_valid
      end
    end

    context "when application email is other email and not nil" do
      let(:params) { { other_application_email: "test2@example.com", application_email: "other" } }

      it "is valid" do
        expect(subject).to be_valid
      end

      it "saves the correct email" do
        expect(subject.params_to_save[:application_email]).to eq(params[:other_application_email])
      end
    end

    context "when application email is other email and nil" do
      let(:params) { { other_application_email: nil, application_email: "other" } }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:other_application_email, :blank)).to be true
      end
    end

    context "when application email is other email and blank" do
      let(:params) { { other_application_email: "", application_email: "other" } }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:other_application_email, :blank)).to be true
      end
    end

    context "when application email is other email and invalid" do
      let(:params) { { other_application_email: "invalidemail", application_email: "other" } }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:other_application_email, :invalid)).to be true
      end
    end

    context "when application email is other email and other email is not nil" do
      let(:params) { { other_application_email: "test2@example.com", application_email: current_publisher.email } }

      it "is valid" do
        expect(subject).to be_valid
      end

      it "saves the correct email" do
        expect(subject.params_to_save[:application_email]).to eq(current_publisher.email)
      end
    end
  end

  describe "application form" do
    context "when application form is not uploaded" do
      let(:vacancy) { build_stubbed(:vacancy, application_form: nil) }
      let(:params) { { application_email: current_publisher.email } }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:application_form, :blank)).to be true
      end
    end

    context "when application form is uploaded" do
      let(:vacancy) { build_stubbed(:vacancy, application_form: application_form) }
      let(:application_form) { fixture_file_upload("blank_job_spec.pdf") }
      let(:params) { { application_email: current_publisher.email } }

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
