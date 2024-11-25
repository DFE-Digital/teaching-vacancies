require "rails_helper"

RSpec.describe MakeJobApplicationPdfJob do
  let(:job_application) { create(:job_application, :status_submitted) }

  it "produces a PDF when called" do
    described_class.perform_now job_application
    expect(job_application.pdf_version).not_to be_nil
  end
end
