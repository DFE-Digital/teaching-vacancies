require "rails_helper"
require "pdf/inspector"

RSpec.describe ReferencePdfGenerator do
  let(:job_reference) { build_stubbed(:job_reference, :reference_given) }
  let(:reference_request) { build_stubbed(:reference_request, job_reference:) }
  let(:referee) { build_stubbed(:referee, reference_request:) }
  let(:presenter) { RefereePresenter.new(referee) }
  let(:generator) { described_class.new(presenter) }

  describe "#generate" do
    subject(:document) { generator.generate }

    let(:pdf) { PDF::Inspector::Text.analyze(document.render).strings }

    it { is_expected.to be_a(Prawn::Document) }

    it "includes page header" do
      expect(pdf).to include("Reference")
    end

    context "when referee can give reference" do
      it "includes section titles" do
        expect(pdf).to include("Referee details")
        expect(pdf).to include("Reference information")
        expect(pdf).to include("Candidate ratings")
      end
    end

    context "when referee cannot give reference" do
      let(:job_reference) { build_stubbed(:job_reference, can_give_reference: false) }

      it "includes section titles" do
        expect(pdf).to include("Referee details")
        expect(pdf).to include("Reference information")
      end
    end

    it "includes page footer" do
      expect(pdf).to include("Reference - #{referee.job_application.name}")
    end

    it "includes page number" do
      expect(pdf).to include("1 of 3")
    end
  end
end
