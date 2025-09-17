require "rails_helper"

RSpec.describe "Publisher can set feedback and declined dates" do
  let(:publisher) { create(:publisher, :with_organisation, accepted_terms_at: 1.day.ago) }
  let(:organisations) { publisher.organisations }
  let(:vacancy) { create(:vacancy, organisations:) }

  before { job_application }

  context "when candidate declines offer", :js do
    let(:job_application) { create(:job_application, :status_declined, vacancy:, declined_at: nil) }

    scenario "add declined date from tab offered" do
      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)
        expect(publisher_ats_applications_page.job_title).to have_text(vacancy.job_title)

        publisher_ats_applications_page.select_tab(:tab_offered)

        expect(publisher_ats_applications_page.tab_panel.job_applications.first.declined_at).to have_link("Add decline date", href: tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_tag_form: { origin: :offered, job_applications: [job_application.id] }, tag_action: "declined" }))

        publisher_ats_applications_page.tab_panel.job_applications.first.declined_at.click_on("Add declined date")

        # Form page
        expect(publisher_ats_job_decline_date_page).to be_displayed(vacancy_id: vacancy.id)
        decline_date = 2.days.ago
        publisher_ats_job_decline_date_page.set_date(decline_date)

        expect(publisher_ats_applications_page).to be_displayed(vacancy_id: vacancy.id)
        expect(publisher_ats_applications_page.tab_panel.job_applications.first.declined_at).to have_text(decline_date.to_fs)
      end
    end
  end

  context "when candidate has an offer", :js do
    let(:job_application) { create(:job_application, :status_offered, vacancy:, offered_at: nil) }

    scenario "add offer date from tab offered" do
      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)
        expect(publisher_ats_applications_page.job_title).to have_text(vacancy.job_title)

        publisher_ats_applications_page.select_tab(:tab_offered)

        expect(publisher_ats_applications_page.tab_panel.job_applications.first.offered_at).to have_link("Add job offer date", href: tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_tag_form: { origin: :offered, job_applications: [job_application.id] }, tag_action: "offered" }))

        publisher_ats_applications_page.tab_panel.job_applications.first.declined_at.click_on("Add job offer date")

        # Form page
        expect(publisher_ats_job_offer_date_page).to be_displayed(vacancy_id: vacancy.id)
        offer_date = 2.days.ago
        publisher_ats_job_offer_date_page.set_date(offer_date)

        expect(publisher_ats_applications_page).to be_displayed(vacancy_id: vacancy.id)
        expect(publisher_ats_applications_page.tab_panel.job_applications.first.offered_at).to have_text(offer_date.to_fs)
      end
    end
  end

  context "when candidate interview is unsuccessful", :js do
    let(:job_application) { create(:job_application, :status_unsuccessful_interview, vacancy:, interview_feedback_received_at: nil) }

    scenario "add declined date from tab offered" do
      run_with_publisher(publisher) do
        publisher_ats_applications_page.load(vacancy_id: vacancy.id)
        expect(publisher_ats_applications_page.job_title).to have_text(vacancy.job_title)

        publisher_ats_applications_page.select_tab(:tab_offered)

        expect(publisher_ats_applications_page.tab_panel.job_applications.first.interview_feedback_received_at).to have_link("Add feedback date", href: tag_organisation_job_job_applications_path(vacancy.id, params: { publishers_job_application_tag_form: { origin: :interviewing, job_applications: [job_application.id] }, tag_action: "feedback" }))

        publisher_ats_applications_page.tab_panel.job_applications.first.interview_feedback_received_at.click_on("Add feedback date")

        # Form page
        expect(publisher_ats_job_feedback_date_page).to be_displayed(vacancy_id: vacancy.id)
        feedback_date = 2.days.ago
        publisher_ats_job_feedback_date_page.set_date(feedback_date)

        expect(publisher_ats_applications_page).to be_displayed(vacancy_id: vacancy.id)
        expect(publisher_ats_applications_page.tab_panel.job_applications.first.interview_feedback_received_at).to have_text(feedback_date.to_fs)
      end
    end
  end
end
