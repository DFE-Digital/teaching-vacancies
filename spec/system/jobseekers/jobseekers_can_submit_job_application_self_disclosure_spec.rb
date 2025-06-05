require "rails_helper"

RSpec.describe "Jobseekers can submit job application self disclosure" do
  include ActiveJob::TestHelper

  let(:jobseeker) { create(:jobseeker) }
  let(:organisations) { [create(:school)] }
  let(:vacancy) { create(:vacancy, organisations:) }
  let(:job_application) { create(:job_application, :status_submitted, vacancy:, jobseeker:) }
  let(:self_disclosure_request) { create(:self_disclosure_request, job_application:) }
  let(:self_disclosure) { create(:self_disclosure, :pending, self_disclosure_request:) }

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
        barred_list: barred_list_errors,
        conduct: conduct_errors,
        confirmation: confirmation_errors,
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

    let(:barred_list_errors) do
      [
        "Select no if you have not been included on the list of people barred from/listed as unsuitable to engage in regulated activity/work with children",
        "Select no if you have not been referred to the Disclosure and Baring Service",
      ]
    end

    let(:conduct_errors) do
      [
        "Select no if you have never been known to any children’s services department",
        "Select no if you have never been dismissed for misconduct from any paid or voluntary position previously held by you",
        "Select no if you have never been under investigation for or subject to any disciplinary sanctions",
        "Select no if you have never been subject to any sanctions being placed on your professional registration",
      ]
    end

    let(:confirmation_errors) do
      [
        "Agree for your information to be processed in order to complete the declaration",
        "Agree criminal record option in order to complete the declaration",
        "Agree to update the school in order to complete the declaration",
        "Agree for information sharing in order to complete the declaration",
      ]
    end

    let(:self_disclosure_data) { build(:self_disclosure) }

    before do
      self_disclosure
      jobseeker_self_disclosure_personal_details_page.load(job_application_id: job_application.id)
    end

    scenario "at first attempt" do
      steps.each do |step_name|
        step = method(:"jobseeker_self_disclosure_#{step_name}_page").call
        expect(page).to have_current_path(jobseekers_job_application_self_disclosure_path(job_application, step_name))
        step.submit_form
        expect(step.errors.map(&:text)).to eq(step_expected_errors[step_name])
        step.fill_in_and_submit_form(self_disclosure_data)
      end

      expect(page).to have_current_path(completed_jobseekers_job_application_self_disclosure_index_path(job_application))
    end
  end
end
