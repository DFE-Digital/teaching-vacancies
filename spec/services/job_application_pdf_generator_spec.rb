require "rails_helper"
require "pdf/inspector"

RSpec.describe JobApplicationPdfGenerator do
  let(:vacancy) { build(:vacancy, :published, :at_one_school) }
  let(:job_application) { build(:job_application, :status_submitted, vacancy: vacancy) }
  let(:generator) { described_class.new(job_application) }

  describe "#generate" do
    subject(:document) { generator.generate }

    let(:pdf) { PDF::Inspector::Text.analyze(document.render).strings }

    it { is_expected.to be_a(Prawn::Document) }

    it "includes page header" do
      expect(pdf).to include(I18n.t("jobseekers.job_applications.caption", job_title: vacancy.job_title, organisation: vacancy.organisation_name))
    end

    it "includes section titles" do
      expect(pdf).to include("Personal Details")
      expect(pdf).to include("Professional Status")
      expect(pdf).to include("Qualifications")
      expect(pdf).to include("Training and continuing professional development (CPD)")
      expect(pdf).to include("Professional body memberships")
      expect(pdf).to include("Work history")
      expect(pdf).to include("Personal statement")
      expect(pdf).to include("References")
      expect(pdf).to include("Ask For Support")
      expect(pdf).to include("Declarations")
    end

    it "includes page footer" do
      expect(pdf).to include("#{job_application.name} | #{vacancy.organisation_name}")
    end

    it "includes page number" do
      expect(pdf).to include("1 of 4")
    end
  end
end
