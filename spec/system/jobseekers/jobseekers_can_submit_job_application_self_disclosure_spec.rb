require "rails_helper"

RSpec.describe "Jobseekers can submit job application self disclosure" do
  include ActiveJob::TestHelper

  let(:jobseeker) { create(:jobseeker) }
  let(:organisations) { [create(:school)] }
  let(:vacancy) { create(:vacancy, organisations:) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy:, jobseeker:) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  after { logout }

  describe "successful declaration" do
    let(:steps) do
      %i[personal_details barred_list conduct confirmation]
    end
    let(:step_expected_errors) do
      {
        personal_details: personal_details_errors,
        barred_list: ["select no"],
        conduct: ["select no"],
        confirmation: ["select no"],
      }
    end

    let(:personal_details_errors) do
      [
        "Enter your name",
        "Enter your building and street",
        "Enter your town or city",
        "Enter your postcode",
        "Enter your phone number",
        "Enter your date of birth",
        "Select no if you have no unspent conditional cautions or convictions in the UK or overseas",
        "Select no if you have no spent conditional cautions or convictions in the UK or overseas",
      ]
    end

    let(:self_disclosure) { create(:self_disclosure, job_application:) }

    before do
      jobseeker_self_disclosure_personal_details_page.load(job_application_id: job_application.id)
    end

    scenario "at first attempt", :js do
      steps.each do |step_name|
        step = method(:"jobseeker_self_disclosure_#{step_name}_page").call
        expect(page).to have_current_path(jobseekers_job_application_self_disclosure_path(job_application, step_name))
        step.submit_form
        expect(step.errors.map(&:text)).to eq(step_expected_errors[step_name])
        step.fill_in_and_submit_form(self_disclosure)
      end

      expect(jobseeker_self_disclosure_completed_page).to be_displayed
    end
  end
end
