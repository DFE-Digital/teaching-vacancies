require "rails_helper"

RSpec.describe EqualOpportunitiesReportUpdateJob do
  subject(:job) { described_class.perform_later(job_application.id) }

  let(:job_application) { create(:job_application, :status_submitted, vacancy:) }
  let(:vacancy) { report.vacancy }
  let(:report) { create(:equal_opportunities_report) }

  before do
    job_application
    perform_enqueued_jobs { job }
    report.reload
  end

  context "when report non existant" do
    let(:vacancy) { create(:vacancy) }

    it { expect(report.total_submissions).to eq(1) }
  end

  context "when report exists" do
    it { expect(report.total_submissions).to eq(2) }
  end
end
