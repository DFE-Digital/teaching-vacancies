require "rails_helper"
require "pdf/inspector"

RSpec.describe JobApplicationPdfGenerator do
  let(:vacancy) { build_stubbed(:vacancy, :at_one_school) }
  let(:job_application) do
    build_stubbed(:job_application, :status_submitted,
                  vacancy: vacancy,
                  referees: build_stubbed_list(:referee, 1, is_most_recent_employer: true),
                  qualifications: build_stubbed_list(:qualification, 3),
                  training_and_cpds: build_stubbed_list(:training_and_cpd, 2))
  end
  let(:generator) { described_class.new(job_application) }

  describe "#generate" do
    subject(:document) { generator.generate }

    let(:pdf) { PDF::Inspector::Text.analyze(document.render).strings }

    it { is_expected.to be_a(Prawn::Document) }

    it "includes page header" do
      expect(pdf).to include(I18n.t("jobseekers.job_applications.caption", job_title: vacancy.job_title, organisation: vacancy.organisation_name))
    end

    it "includes section titles" do
      expect(pdf).to include("Personal details")
      expect(pdf).to include("Professional status")
      expect(pdf).to include("Qualifications")
      expect(pdf).to include("Training and continuing professional development (CPD)")
      expect(pdf).to include("Professional body memberships")
      expect(pdf).to include("Work history")
      expect(pdf).to include("Personal statement")
      expect(pdf).to include("References")
      expect(pdf).to include("Ask for support if you have a disability or other needs")
      expect(pdf).to include("Declarations")
    end

    it "includes page footer" do
      expect(pdf).to include("#{job_application.name} | #{vacancy.organisation_name}")
    end

    it "includes page number" do
      expect(pdf).to include("1 of 4")
    end

    context "when vacancy religion type is no_religion" do
      let(:vacancy) { build_stubbed(:vacancy, :at_one_school, religion_type: "no_religion") }

      it "generates PDF without religious information section" do
        expect { document }.not_to raise_error
        expect(document).to be_a(Prawn::Document)
        expect(pdf).not_to include("Religious information")
      end
    end

    context "when the religion reference data is a baptism certificate" do
      let(:vacancy) { build_stubbed(:vacancy, :catholic) }
      let(:job_application) do
        build_stubbed(:job_application, :status_submitted, :with_baptism_certificate, vacancy:)
      end

      it "generates PDF with the baptism certificate file name" do
        expect { document }.not_to raise_error
        expect(document).to be_a(Prawn::Document)
        expect(pdf).to include("blank_job_spec.pdf")
      end
    end
  end
end
