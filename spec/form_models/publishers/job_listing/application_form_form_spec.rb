require "rails_helper"

RSpec.describe Publishers::JobListing::ApplicationFormForm, type: :model do
  subject { described_class.new(params, vacancy) }

  let(:vacancy) { build_stubbed(:vacancy, application_form: application_form) }

  describe "application form" do
    context "when application form is not uploaded" do
      let(:vacancy) { build_stubbed(:vacancy, application_form: nil) }
      let(:params) { {} }

      it "is invalid" do
        expect(subject).to be_invalid
        expect(subject.errors.of_kind?(:application_form, :blank)).to be true
      end
    end

    context "when application form is uploaded" do
      let(:vacancy) { build_stubbed(:vacancy, application_form: application_form) }
      let(:application_form) { fixture_file_upload("blank_job_spec.pdf") }
      let(:params) { {} }

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
