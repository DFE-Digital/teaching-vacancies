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
  let(:presenter) { JobApplicationPdf.new(job_application) }
  let(:generator) { described_class.new(presenter) }

  describe "#generate" do
    subject(:document) { generator.generate }

    let(:pdf) { PDF::Inspector::Text.analyze(document.render).strings }

    # One example for everything read from the default document: rendering the PDF is the slow part.
    it "renders the header, every section, the footer and the page number", :aggregate_failures do
      expect(document).to be_a(Prawn::Document)

      expect(pdf).to include(I18n.t("jobseekers.job_applications.caption", job_title: vacancy.job_title, organisation: vacancy.organisation_name))

      expect(pdf).to include("Personal details")
      expect(pdf).to include("Professional status")
      expect(pdf).to include("Qualifications")
      expect(pdf).to include("Training and continuing professional development (CPD)")
      expect(pdf).to include("Professional body memberships")
      expect(pdf).to include("Work history")
      expect(pdf).to include("Personal statement")
      expect(pdf).to include("References")
      expect(pdf).to include("Do you need support or adjustments for your interview?")
      expect(pdf).to include("Declarations")

      expect(pdf).to include("#{job_application.name} | #{vacancy.organisation_name}")
      expect(pdf).to include("1 of 5")

      # only a blank job application asks for a confirmation
      expect(pdf).not_to include("I confirm that the above information is accurate and complete")
    end

    describe "render_confirmation" do
      context "when blank job application presenter" do
        let(:presenter) { BlankJobApplicationPdf.new(job_application) }

        it { expect(pdf).to include("I confirm that the above information is accurate and complete") }
      end
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
