require "rails_helper"

RSpec.describe "Jobseekers can review a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:organisation) { create(:school) }
  let(:job_application) { create(:job_application, jobseeker: jobseeker, vacancy: vacancy) }

  let(:review_page) { PageObjects::Jobseekers::JobApplications::Review.new }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
    review_page.load(job_application_id: job_application.id)
  end

  it "displays all the job application information" do
    review_page.steps(text: I18n.t("jobseekers.job_applications.build.personal_details.heading")).first.within do |personal_details|
      %w[first_name last_name previous_names phone_number teacher_reference_number national_insurance_number].each do |attribute|
        expect(personal_details.body.rows(id: "personal_details_#{attribute}").first.value.text).to eq(job_application[attribute])
      end
      expect(personal_details.body.rows(id: "personal_details_your_address").first.value.text).to include(job_application.street_address)
      expect(personal_details.body.rows(id: "personal_details_your_address").first.value.text).to include(job_application.city)
      expect(personal_details.body.rows(id: "personal_details_your_address").first.value.text).to include(job_application.postcode)
      expect(personal_details.body.rows(id: "personal_details_your_address").first.value.text).to include(job_application.country)
    end

    review_page.steps(text: I18n.t("jobseekers.job_applications.build.professional_status.heading")).first.within do |professional_status|
      expect(professional_status.body.rows(id: "professional_status_qualified_teacher_status").first.value.text).to include(job_application.qualified_teacher_status.capitalize)
      expect(professional_status.body.rows(id: "professional_status_qualified_teacher_status").first.value.text).to include(job_application.qualified_teacher_status_year)
      expect(professional_status.body.rows(id: "professional_status_statutory_induction_complete").first.value.text).to eq(job_application.statutory_induction_complete.capitalize)
    end

    job_application.employments.order(:created_at).each_with_index do |employment_details, index|
      review_page.steps(text: I18n.t("jobseekers.job_applications.build.employment_history.heading")).first.within do |employment|
        employment.body.accordions(text: employment_details.job_title, id: "employment_history_#{index}").first.within do |accordion|
          expect(accordion.content.rows(id: "employment_history_organisation").first.value.text).to eq(employment_details.organisation)
          expect(accordion.content.rows(id: "employment_history_salary").first.value.text).to eq(employment_details.salary)
          expect(accordion.content.rows(id: "employment_history_subjects").first.value.text).to eq(employment_details.subjects)
          expect(accordion.content.rows(id: "employment_history_main_duties").first.value.text).to eq(employment_details.main_duties)
          expect(accordion.content.rows(id: "employment_history_started_on").first.value.text).to eq(employment_details.started_on.to_s.strip)
          expect(accordion.content.rows(id: "employment_history_current_role").first.value.text).to eq(employment_details.current_role.capitalize)
          expect(accordion.content.rows(id: "employment_history_ended_on").first.value.text).to eq(employment_details.ended_on.to_s.strip)
        end
      end
    end

    review_page.steps(text: I18n.t("jobseekers.job_applications.build.personal_statement.heading")).first.within do |personal_statement|
      expect(personal_statement.body.text).to eq(job_application.personal_statement)
    end

    job_application.references.order(:created_at).each_with_index do |reference_details, index|
      review_page.steps(text: I18n.t("jobseekers.job_applications.build.references.heading")).first.within do |reference|
        reference.body.accordions(text: reference_details.name, id: "reference_#{index}").first.within do |accordion|
          expect(accordion.content.rows(id: "reference_job_title").first.value.text).to eq(reference_details.job_title)
          expect(accordion.content.rows(id: "reference_organisation").first.value.text).to eq(reference_details.organisation)
          expect(accordion.content.rows(id: "reference_relationship").first.value.text).to eq(reference_details.relationship)
          expect(accordion.content.rows(id: "reference_email").first.value.text).to eq(reference_details.email)
          expect(accordion.content.rows(id: "reference_phone_number").first.value.text).to eq(reference_details.phone_number)
        end
      end
    end

    review_page.steps(text: I18n.t("jobseekers.job_applications.build.equal_opportunities.heading")).first.within do |equal_opportunities|
      expect(equal_opportunities.body.rows(id: "equal_opportunities_disability").first.value.text).to eq(job_application.disability.capitalize)
      expect(equal_opportunities.body.rows(id: "equal_opportunities_gender").first.value.text).to include(job_application.gender.capitalize)
      expect(equal_opportunities.body.rows(id: "equal_opportunities_gender").first.value.text).to include(job_application.gender_description.capitalize)
      expect(equal_opportunities.body.rows(id: "equal_opportunities_orientation").first.value.text).to include(job_application.orientation.capitalize)
      expect(equal_opportunities.body.rows(id: "equal_opportunities_orientation").first.value.text).to include(job_application.orientation_description.capitalize)
      expect(equal_opportunities.body.rows(id: "equal_opportunities_ethnicity").first.value.text).to include(job_application.ethnicity.capitalize)
      expect(equal_opportunities.body.rows(id: "equal_opportunities_ethnicity").first.value.text).to include(job_application.ethnicity_description.capitalize)
      expect(equal_opportunities.body.rows(id: "equal_opportunities_religion").first.value.text).to include(job_application.religion.capitalize)
      expect(equal_opportunities.body.rows(id: "equal_opportunities_religion").first.value.text).to include(job_application.religion_description.capitalize)
    end

    review_page.steps(text: I18n.t("jobseekers.job_applications.build.ask_for_support.heading")).first.within do |ask_for_support|
      expect(ask_for_support.body.rows(id: "ask_for_support_support_needed").first.value.text).to include(job_application.support_needed.capitalize)
      expect(ask_for_support.body.rows(id: "ask_for_support_support_needed").first.value.text).to include(job_application.support_needed_details)
    end

    review_page.steps(text: I18n.t("jobseekers.job_applications.build.declarations.heading")).first.within do |declarations|
      expect(declarations.body.rows(id: "declarations_close_relationships").first.value.text).to include(job_application.close_relationships.capitalize)
      expect(declarations.body.rows(id: "declarations_close_relationships").first.value.text).to include(job_application.close_relationships_details)
      expect(declarations.body.rows(id: "declarations_right_to_work_in_uk").first.value.text).to eq(job_application.right_to_work_in_uk.capitalize)
    end
  end
end
