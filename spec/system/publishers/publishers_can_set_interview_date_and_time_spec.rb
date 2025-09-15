require "rails_helper"

RSpec.describe "Publisher can manully set interview date and time" do
  let(:publisher) { create(:publisher, :with_organisation, accepted_terms_at: 1.day.ago) }
  let(:organisations) { publisher.organisations }
  let(:vacancy) { create(:vacancy, organisations:) }
  let(:job_application) { create(:job_application, :status_interviewing, vacancy:, interviewing_at: nil) }

  before { job_application }

  scenario "Add interview date and time from interviewing tab", :js do
    run_with_publisher(publisher) do
      publisher_ats_applications_page.load(vacancy_id: vacancy.id)
      expect(publisher_ats_applications_page.job_title).to have_text(vacancy.job_title)

      publisher_ats_applications_page.select_tab(:tab_interviewing)
      expect(publisher_ats_applications_page.tab_panel.job_applications.first.interview_date).to have_link("Add interview date and time", href: tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_tag_form: { origin: :interviewing, job_applications: [job_application.id] }, tag_action: "interview_datetime" }))

      publisher_ats_applications_page.tab_panel.job_applications.first.interview_date.click_on("Add interview date and time")

      # Form page
      expect(publisher_ats_interview_datetime_page).to be_displayed(vacancy_id: vacancy.id)
      interview_date = 2.days.from_now
      interview_datetime = Time.zone.local(
        interview_date.year,
        interview_date.month,
        interview_date.day,
        10,
        45,
      )
      publisher_ats_interview_datetime_page.fill_and_submit(interview_datetime)

      expect(publisher_ats_applications_page).to be_displayed(vacancy_id: vacancy.id)
      expect(publisher_ats_applications_page.tab_panel.job_applications.first.interview_date).to have_text(interview_datetime.to_fs.strip)
    end
  end

  scenario "Add interview date and time from job application show page", :js do
    run_with_publisher(publisher) do
      publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)

      expect(publisher_application_page).to have_link("Add interview date and time", href: tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_interview_datetime_form: { origin: :interviewing, job_applications: [job_application.id] }, tag_action: "interview_datetime", form_name: "InterviewDatetimeForm" }))

      publisher_application_page.click_on("Add interview date and time")

      # Form page
      expect(publisher_ats_interview_datetime_page).to be_displayed(vacancy_id: vacancy.id)
      interview_date = 4.days.from_now
      interview_datetime = Time.zone.local(
        interview_date.year,
        interview_date.month,
        interview_date.day,
        10,
        45,
      )
      publisher_ats_interview_datetime_page.fill_and_submit(interview_datetime)

      expect(publisher_ats_applications_page).to be_displayed(vacancy_id: vacancy.id)
      expect(publisher_ats_applications_page.tab_panel.job_applications.first.interview_date).to have_text(interview_datetime.to_fs.strip)
    end
  end

  scenario "Change interview date and time from job application show page", :js do
    run_with_publisher(publisher) do
      job_application.update!(interviewing_at: 1.day.from_now)
      publisher_application_page.load(vacancy_id: vacancy.id, job_application_id: job_application.id)

      expect(publisher_application_page).to have_link("Change interview date and time", href: tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_interview_datetime_form: { origin: :interviewing, job_applications: [job_application.id] }, tag_action: "interview_datetime", form_name: "InterviewDatetimeForm" }))

      publisher_application_page.click_on("Change interview date and time")

      # Form page
      expect(publisher_ats_interview_datetime_page).to be_displayed(vacancy_id: vacancy.id)
      interview_date = 4.days.from_now
      interview_datetime = Time.zone.local(
        interview_date.year,
        interview_date.month,
        interview_date.day,
        10,
        45,
      )
      publisher_ats_interview_datetime_page.fill_and_submit(interview_datetime)

      expect(publisher_ats_applications_page).to be_displayed(vacancy_id: vacancy.id)
      expect(publisher_ats_applications_page.tab_panel.job_applications.first.interview_date).to have_text(interview_datetime.to_fs.strip)
    end
  end
end
