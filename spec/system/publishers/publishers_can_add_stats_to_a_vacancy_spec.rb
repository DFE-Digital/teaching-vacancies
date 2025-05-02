require "rails_helper"

RSpec.describe "Submitting effectiveness statistics on expired vacancies" do
  let(:school) { create(:school) }
  let(:publisher) { create(:publisher) }

  before do
    login_publisher(publisher: publisher, organisation: school)
  end

  after { logout }

  context "when there are vacancies awaiting feedback" do
    let!(:vacancy) { create(:vacancy, :expired, job_title: "Maths teacher", organisations: [school]) }
    let!(:another_vacancy) { create(:vacancy, :expired, job_title: "English teacher", organisations: [school]) }
    let!(:third_vacancy) { create(:vacancy, :expired, job_title: "Science teacher", organisations: [school]) }

    before do
      publisher_applications_awaiting_feedback_page.load
    end

    scenario "displays the vacancies awaiting feedback" do
      expect(publisher_applications_awaiting_feedback_page).to be_displayed

      expect(page).to have_link(vacancy.job_title, href: organisation_job_path(vacancy.id))
      expect(page).to have_link(another_vacancy.job_title, href: organisation_job_path(another_vacancy.id))
      expect(page).to have_link(third_vacancy.job_title, href: organisation_job_path(third_vacancy.id))

      submit_feedback_for(vacancy)

      expect(page).not_to have_link(vacancy.job_title, href: organisation_job_path(vacancy.id))
    end

    scenario "it saves feedback to the correct record" do
      expect(publisher_applications_awaiting_feedback_page).to be_displayed

      submit_feedback_for(another_vacancy)

      another_vacancy.reload
      expect(another_vacancy.hired_status).to eq("hired_tvs")
      expect(another_vacancy.listed_elsewhere).to eq("listed_paid")
    end

    context "when an invalid form is submitted" do
      scenario "it renders the errors on the correct form" do
        expect(publisher_applications_awaiting_feedback_page).to be_displayed

        within(".feedback-row", text: vacancy.job_title) do
          click_on I18n.t("buttons.submit")
        end

        within("##{vacancy.id}") do
          expect(page).to have_content(I18n.t("errors.publishers.job_statistics.error_summary", job_title: vacancy.job_title))
        end
      end
    end
  end

  context "when adding feedback to an invalid vacancy" do
    let!(:invalid_vacancy) do
      create(:vacancy, :expired, starts_on: 10.days.ago, organisations: [school])
    end

    before do
      publisher_applications_awaiting_feedback_page.load
    end

    scenario "it saves the feedback to the model without triggering validation errors" do
      expect(publisher_applications_awaiting_feedback_page).to be_displayed

      submit_feedback_for(invalid_vacancy)

      invalid_vacancy.reload
      expect(invalid_vacancy.hired_status).to eq("hired_tvs")
      expect(invalid_vacancy.listed_elsewhere).to eq("listed_paid")
    end
  end

  context "when all feedback has been submitted" do
    let!(:vacancy) do
      create(:vacancy, :expired,
             hired_status: "hired_tvs",
             listed_elsewhere: "listed_paid",
             organisations: [school])
    end

    before do
      publisher_applications_awaiting_feedback_page.load
    end

    scenario "the no vacancies component is displayed" do
      expect(publisher_applications_awaiting_feedback_page).to be_displayed

      expect(page).not_to have_link(vacancy.job_title, href: organisation_job_path(vacancy.id))
      expect(page).to have_content(I18n.t("jobs.manage.awaiting_feedback.no_jobs.no_filters"))
    end
  end

  def submit_feedback_for(vacancy)
    within(".feedback-row", text: vacancy.job_title) do
      select I18n.t("jobs.feedback.hired_status.hired_tvs"), from: "publishers_vacancy_statistics_form[hired_status]"
      select I18n.t("jobs.feedback.listed_elsewhere.listed_paid"), from: "publishers_vacancy_statistics_form[listed_elsewhere]"
      click_on I18n.t("buttons.submit")
    end

    expect(page).to have_content(
      strip_tags(I18n.t("publishers.vacancies.statistics.update.success", job_title: vacancy.job_title)),
    )
  end
end
