require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/tag" do
  let(:vacancy) do
    create(:vacancy, :published, job_applications: [create(:job_application, :submitted)])
  end

  before do
    assign :job_applications, vacancy.job_applications
    without_partial_double_verification do
      allow(view).to receive(:vacancy).and_return(vacancy)
    end
    render
  end

  describe "form options" do
    JobApplicationsHelper::JOB_APPLICATION_DISPLAYED_STATUSES.each do |status|
      it "shows a radia button for status '#{status}'" do
        expect(rendered).to have_css("#publishers-job-application-status-form-status-#{status}-field")
      end
    end
  end
end
