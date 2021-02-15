require "rails_helper"

RSpec.describe "NQT job alerts", recaptcha: true, vcr: { cassette_name: "algoliasearch" } do
  before do
    visit nqt_job_alerts_path
  end

  describe "A jobseeker" do
    scenario "can successfully subscribe to a job alert" do
      expect(page).to have_content(I18n.t("nqt_job_alerts.heading"))

      fill_in_nqt_job_alert_form

      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(SubscriptionMailer).to receive(:confirmation) { message_delivery }
      expect(message_delivery).to receive(:deliver_later)
      click_on I18n.t("buttons.subscribe")

      expect(page).to have_content(I18n.t("nqt_job_alerts.confirm.heading"))
      click_on I18n.t("buttons.go_to_teaching_vacancies")

      expect(page).to have_current_path(jobs_path(keyword: "nqt Maths", location: "Clitheroe"))
    end
  end

  context "when verify_recaptcha is false" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(false)
    end

    context "and the form is valid" do
      scenario "redirects to invalid_recaptcha path" do
        fill_in_nqt_job_alert_form
        click_on I18n.t("buttons.subscribe")
        expect(page).to have_current_path(invalid_recaptcha_path(form_name: "Jobseekers/nqt job alerts form"))
      end
    end

    context "and the form is invalid" do
      scenario "does not redirect to invalid_recaptcha path" do
        click_on I18n.t("buttons.subscribe")
        expect(page).to have_content("There is a problem")
      end
    end
  end

  def fill_in_nqt_job_alert_form
    fill_in "jobseekers_nqt_job_alerts_form[keywords]", with: "Maths"
    fill_in "jobseekers_nqt_job_alerts_form[location]", with: "Clitheroe"
    fill_in "jobseekers_nqt_job_alerts_form[email]", with: "test@email.com"
  end
end
