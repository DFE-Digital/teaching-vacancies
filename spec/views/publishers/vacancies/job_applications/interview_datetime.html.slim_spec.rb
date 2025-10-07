require "rails_helper"

RSpec.describe "publishers/vacancies/job_applications/interview_datetime" do
  let(:form) { Publishers::JobApplication::InterviewDatetimeForm.new(job_applications:, interview_date:, interview_time:) }
  let(:job_applications) { build_stubbed_list(:job_application, 1, :status_interviewing) }
  let(:interview_date) { Date.new(2025, 9, 1) }
  let(:interview_time) { Time.zone.parse("9am") }
  let(:form_page) { Capybara.string(rendered) }

  before do
    assign :form, form
    without_partial_double_verification do
      allow(view).to receive(:vacancy).and_return(job_applications.first.vacancy)
    end
    render
  end

  describe "heading" do
    it "contains candidate's name" do
      expect(form_page.find("h1")).to have_text(job_applications.first.name)
    end
  end

  describe "form" do
    it "contains interview date input" do
      expect(form_page).to have_css("#publishers_job_application_interview_datetime_form_interview_date_1i")
      expect(form_page).to have_css("#publishers_job_application_interview_datetime_form_interview_date_2i")
      expect(form_page).to have_css("#publishers_job_application_interview_datetime_form_interview_date_3i")
    end

    it "contains interview time input" do
      expect(form_page).to have_css("#publishers-job-application-interview-datetime-form-interview-time-field")
    end
  end
end
