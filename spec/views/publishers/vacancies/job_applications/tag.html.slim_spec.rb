require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/tag" do
  let(:vacancy) do
    build_stubbed(:vacancy, job_applications: [build_stubbed(:job_application, :submitted)])
  end
  let(:form) { Publishers::JobApplication::TagForm.new(job_applications:, status:, origin:) }
  let(:job_applications) { vacancy.job_applications }
  let(:status) { "shortlisted" }
  let(:origin) { "submitted" }

  before do
    assign :form, form
    without_partial_double_verification do
      allow(view).to receive(:vacancy).and_return(vacancy)
    end
    render
  end

  describe "form options" do
    context "when origin is new tab" do
      let(:origin) { "submitted" }

      %i[reviewed unsuccessful shortlisted interviewing offered].each do |status|
        it "shows a radio button for status '#{status}'" do
          expect(rendered).to have_css("#publishers-job-application-tag-form-status-#{status}-field")
        end
      end
    end

    context "when origin is shortlisted tab" do
      let(:origin) { "shortlisted" }

      %i[unsuccessful interviewing offered].each do |status|
        it "shows a radio button for status '#{status}'" do
          expect(rendered).to have_css("#publishers-job-application-tag-form-status-#{status}-field")
        end
      end
    end

    context "when origin is interviewing tab" do
      let(:origin) { "interviewing" }

      %i[unsuccessful offered].each do |status|
        it "shows a radio button for status '#{status}'" do
          expect(rendered).to have_css("#publishers-job-application-tag-form-status-#{status}-field")
        end
      end
    end
  end
end
