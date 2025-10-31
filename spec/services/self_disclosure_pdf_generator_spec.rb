require "rails_helper"
require "pdf/inspector"

RSpec.describe SelfDisclosurePdfGenerator do
  let(:vacancy) { create(:vacancy, :at_one_school) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy: vacancy) }
  let(:self_disclosure_request) { create(:self_disclosure_request, job_application:, status: "received") }
  let(:self_disclosure) { create(:self_disclosure, self_disclosure_request:) }
  let(:presenter) { SelfDisclosurePresenter.new(job_application) }
  let(:generator) { described_class.new(presenter) }

  before { self_disclosure }

  describe "#generate" do
    subject(:document) { generator.generate }

    let(:scope) { "jobseekers.job_applications.self_disclosure.review.completed" }

    let(:pdf) { PDF::Inspector::Text.analyze(document.render).strings }

    it { is_expected.to be_a(Prawn::Document) }

    it "includes page header" do
      expect(pdf).to include(I18n.t(".self_disclosure_form", scope:))
    end

    it "includes section titles" do
      expect(pdf).to include("Personal details")
      expect(pdf).to include("Criminal record self-disclosure")
      expect(pdf).to include("Conduct self-disclosure")
      expect(pdf).to include("Confirmation self-disclosure")
    end

    it "includes page footer" do
      expect(pdf).to include("#{I18n.t('.self_disclosure_form', scope:)} - #{job_application.name}")
    end

    it "includes page number" do
      expect(pdf).to include("1 of 3")
    end
  end
end
