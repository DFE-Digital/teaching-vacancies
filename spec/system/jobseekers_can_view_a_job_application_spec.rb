require "rails_helper"

RSpec.describe "Jobseekers can view a job application" do
  let(:jobseeker) { create(:jobseeker) }
  let(:vacancy) { create(:vacancy, organisation_vacancies_attributes: [{ organisation: organisation }]) }
  let(:organisation) { create(:school) }
  let(:job_application) { create(:job_application, :status_submitted, jobseeker: jobseeker, vacancy: vacancy) }

  let(:show_page) { PageObjects::Jobseekers::JobApplications::Show.new }

  before do
    allow(JobseekerApplicationsFeature).to receive(:enabled?).and_return(true)
    login_as(jobseeker, scope: :jobseeker)
    show_page.load(id: job_application.id)
  end

  it "displays all the job application information" do
    expect(show_page.banner.job_title.text).to eq(vacancy.job_title)

    expect(show_page.banner.status.text).to eq(job_application.status)

    expect(show_page.timeline.items(text: I18n.t("jobseekers.job_applications.status_timestamps.submitted")).first.text)
      .to include(format_date(job_application.submitted_at.to_date) + I18n.t("jobs.time_at") + format_time(job_application.submitted_at))

    expect(page).not_to have_content(I18n.t("jobseekers.job_applications.show.shortlist_alert.title"))
    expect(page).not_to have_content(I18n.t("jobseekers.job_applications.show.feedback"))

    show_page.steps(text: I18n.t("jobseekers.job_applications.build.personal_details.heading")).first.within do |personal_details|
      %w[first_name last_name previous_names phone_number teacher_reference_number national_insurance_number].each do |attribute|
        expect(personal_details.body.rows(id: "personal_details_#{attribute}").first.value.text).to eq(job_application[attribute])
      end
      expect(personal_details.body.rows(id: "personal_details_your_address").first.value.text).to include(job_application.street_address)
      expect(personal_details.body.rows(id: "personal_details_your_address").first.value.text).to include(job_application.city)
      expect(personal_details.body.rows(id: "personal_details_your_address").first.value.text).to include(job_application.postcode)
    end

    show_page.steps(text: I18n.t("jobseekers.job_applications.build.professional_status.heading")).first.within do |professional_status|
      expect(professional_status.body.rows(id: "professional_status_qualified_teacher_status").first.value.text).to include(job_application.qualified_teacher_status.capitalize)
      expect(professional_status.body.rows(id: "professional_status_qualified_teacher_status").first.value.text).to include(job_application.qualified_teacher_status_year)
      expect(professional_status.body.rows(id: "professional_status_statutory_induction_complete").first.value.text).to eq(job_application.statutory_induction_complete.capitalize)
    end

    job_application.employments.order(:created_at).each_with_index do |employment_details, index|
      show_page.steps(text: I18n.t("jobseekers.job_applications.build.employment_history.heading")).first.within do |employment|
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

    show_page.steps(text: I18n.t("jobseekers.job_applications.build.personal_statement.heading")).first.within do |personal_statement|
      expect(personal_statement.body.text).to eq(job_application.personal_statement)
    end

    job_application.references.order(:created_at).each_with_index do |reference_details, index|
      show_page.steps(text: I18n.t("jobseekers.job_applications.build.references.heading")).first.within do |reference|
        reference.body.accordions(text: reference_details.name, id: "reference_#{index}").first.within do |accordion|
          expect(accordion.content.rows(id: "reference_job_title").first.value.text).to eq(reference_details.job_title)
          expect(accordion.content.rows(id: "reference_organisation").first.value.text).to eq(reference_details.organisation)
          expect(accordion.content.rows(id: "reference_relationship").first.value.text).to eq(reference_details.relationship)
          expect(accordion.content.rows(id: "reference_email").first.value.text).to eq(reference_details.email)
          expect(accordion.content.rows(id: "reference_phone_number").first.value.text).to eq(reference_details.phone_number)
        end
      end
    end

    show_page.steps(text: I18n.t("jobseekers.job_applications.build.ask_for_support.heading")).first.within do |ask_for_support|
      expect(ask_for_support.body.rows(id: "ask_for_support_support_needed").first.value.text).to include(job_application.support_needed.capitalize)
      expect(ask_for_support.body.rows(id: "ask_for_support_support_needed").first.value.text).to include(job_application.support_needed_details)
    end

    show_page.steps(text: I18n.t("jobseekers.job_applications.build.declarations.heading")).first.within do |declarations|
      expect(declarations.body.rows(id: "declarations_banned_or_disqualified").first.value.text).to eq(job_application.banned_or_disqualified.capitalize)
      expect(declarations.body.rows(id: "declarations_close_relationships").first.value.text).to include(job_application.close_relationships.capitalize)
      expect(declarations.body.rows(id: "declarations_close_relationships").first.value.text).to include(job_application.close_relationships_details)
      expect(declarations.body.rows(id: "declarations_right_to_work_in_uk").first.value.text).to eq(job_application.right_to_work_in_uk.capitalize)
    end
  end

  context "when job application status is shortlisted" do
    let(:job_application) { create(:job_application, :status_shortlisted, jobseeker: jobseeker, vacancy: vacancy) }

    it "displays what happens next notification, status and shortlisted date" do
      expect(page).to have_content(I18n.t("jobseekers.job_applications.show.shortlist_alert.title"))

      expect(show_page.banner.status.text).to eq("shortlisted")

      expect(show_page.timeline).not_to have_items(text: I18n.t("jobseekers.job_applications.status_timestamps.unsuccessful"))
      expect(show_page.timeline).to have_items(text: I18n.t("jobseekers.job_applications.status_timestamps.shortlisted"))
      expect(show_page.timeline).to have_items(text: I18n.t("jobseekers.job_applications.status_timestamps.submitted"))

      expect(show_page.timeline.items(text: I18n.t("jobseekers.job_applications.status_timestamps.shortlisted")).first.text)
        .to include(format_date(job_application.shortlisted_at.to_date))
      expect(show_page.timeline.items(text: I18n.t("jobseekers.job_applications.status_timestamps.submitted")).first.text)
        .to include(format_date(job_application.submitted_at.to_date) + I18n.t("jobs.time_at") + format_time(job_application.submitted_at))
    end
  end

  context "when job application status is unsuccessful" do
    let(:job_application) { create(:job_application, :status_unsuccessful, jobseeker: jobseeker, vacancy: vacancy) }

    it "displays feedback, status and unsuccessful date" do
      expect(page).to have_content(I18n.t("jobseekers.job_applications.show.feedback"))
      expect(page).to have_content(job_application.rejection_reasons)

      expect(show_page.banner.status.text).to eq("unsuccessful")

      expect(show_page.timeline).to have_items(text: I18n.t("jobseekers.job_applications.status_timestamps.unsuccessful"))
      expect(show_page.timeline).not_to have_items(text: I18n.t("jobseekers.job_applications.status_timestamps.shortlisted"))
      expect(show_page.timeline).to have_items(text: I18n.t("jobseekers.job_applications.status_timestamps.submitted"))

      expect(show_page.timeline.items(text: I18n.t("jobseekers.job_applications.status_timestamps.unsuccessful")).first.text)
        .to include(format_date(job_application.unsuccessful_at.to_date))
      expect(show_page.timeline.items(text: I18n.t("jobseekers.job_applications.status_timestamps.submitted")).first.text)
        .to include(format_date(job_application.submitted_at.to_date) + I18n.t("jobs.time_at") + format_time(job_application.submitted_at))
    end
  end
end
