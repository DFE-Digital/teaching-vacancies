# frozen_string_literal: true

require "rails_helper"

RSpec.describe JobApplicationDecorator do
  describe "#submitted_application_form" do
    subject(:document) { job_application.decorate.submitted_application_form }

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

  describe "#first_name" do
    subject(:first) { job_application.decorate.first_name }

    let(:first_name) { Faker::Name.first_name }
    let(:job_application) { build_stubbed(:job_application, :status_submitted, vacancy: vacancy, first_name: first_name) }

    context "with a normal vacancy" do
      let(:vacancy) { build_stubbed(:vacancy) }

      it "shows the name" do
        expect(first).to eq(first_name)
      end
    end

    context "with an anonymised vacancy" do
      let(:vacancy) { build_stubbed(:vacancy, anonymise_applications: true) }

      it "does not show the name" do
        expect(first).not_to eq(first_name)
      end
    end
  end
end
