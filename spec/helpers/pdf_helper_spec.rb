require "rails_helper"
require "prawn"
require "pdf/inspector"


RSpec.describe JobApplicationPdfGenerator, type: :service do
  let(:job_application) { create(:job_application, vacancy: vacancy) }
  let(:vacancy) { create(:vacancy) }
  let(:pdf_generator) { JobApplicationPdfGenerator.new(job_application, vacancy) }

  describe "#generate" do
    let(:pdf) { pdf_generator.generate.render }
    let(:text_analysis) { PDF::Inspector::Text.analyze(pdf) }

    it "generates a valid PDF document" do
      expect(pdf).to be_a(String)
    end

    it "renders the PDF without errors" do
      expect { pdf_generator.generate.render }.not_to raise_error
    end

    it "includes the applicant’s name" do
      expect(text_analysis.strings).to include(job_application.first_name)
    end

    it "includes the job title and organization" do
      header = I18n.t("jobseekers.job_applications.caption", job_title: vacancy.job_title, organisation: vacancy.organisation_name)
      expect(text_analysis.strings).to include(header)
    end

    it "includes section titles" do
      expect(text_analysis.strings).to include("Personal Details")
      expect(text_analysis.strings).to include("Professional Status")
      expect(text_analysis.strings).to include("Qualifications")
      expect(text_analysis.strings).to include("Employment History")
      expect(text_analysis.strings).to include("Personal Statement")
      expect(text_analysis.strings).to include("References")
      expect(text_analysis.strings).to include("Ask for Support")
      expect(text_analysis.strings).to include("Declarations")
    end

    it "includes the applicant's personal details" do
      expect(text_analysis.strings).to include(job_application.first_name)
      expect(text_analysis.strings).to include(job_application.last_name)
      expect(text_analysis.strings).to include(job_application.email_address)
      expect(text_analysis.strings).to include(job_application.phone_number)
    end
  end
end
