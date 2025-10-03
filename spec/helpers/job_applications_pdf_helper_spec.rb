require "rails_helper"

RSpec.describe JobApplicationsPdfHelper do
  describe "#submitted_application_form" do
    subject(:document) { submitted_application_form(job_application) }

    context "with uploaded application form" do
      let(:vacancy) { build_stubbed(:vacancy, :with_uploaded_application_form) }

      context "when application form is attached" do
        let(:job_application) do
          create(:uploaded_job_application,
                 :with_uploaded_application_form,
                 :status_submitted)
        end

        it { expect(document.filename).to eq("application_form.pdf") }
        it { expect(document.data).to be_present }
      end

      context "when uploaded application form is not attached" do
        let(:job_application) do
          build_stubbed(:uploaded_job_application, :status_submitted)
        end

        it { expect(document.filename).to eq("no_application_form.txt") }
        it { expect(document.data).to eq("the candidate has no application for on record") }
      end
    end

    context "with TV application form" do
      let(:job_application) { build_stubbed(:job_application, :status_submitted) }

      it { expect(document.filename).to eq("application_form.pdf") }
      it { expect(document.data).to include("%PDF-") }
    end
  end
end
