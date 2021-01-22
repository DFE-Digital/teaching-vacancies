require "rails_helper"

RSpec.describe "NQT job alerts" do
  describe "A jobseeker" do
    scenario "can successfully subscribe to a job alert" do
      visit nqt_job_alerts_path

      expect(page).to have_content(I18n.t("nqt_job_alerts.heading"))

      fill_in "jobseekers_nqt_job_alerts_form[keywords]", with: "Maths"
      fill_in "jobseekers_nqt_job_alerts_form[location]", with: "London"
      fill_in "jobseekers_nqt_job_alerts_form[email]", with: "test@email.com"

      message_delivery = instance_double(ActionMailer::MessageDelivery)
      expect(SubscriptionMailer).to receive(:confirmation) { message_delivery }
      expect(message_delivery).to receive(:deliver_later)
      click_on I18n.t("buttons.subscribe")

      expect(page).to have_content(I18n.t("nqt_job_alerts.confirm.heading"))
      click_on I18n.t("buttons.go_to_teaching_vacancies")

      expect(page).to have_current_path(jobs_path(keyword: "nqt Maths", location: "London"))
    end
  end

  context "when recaptcha score is invalid" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:verify_recaptcha).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:recaptcha_reply).and_return({ "score" => 0.1 })
    end

    scenario "redirects to invalid_recaptcha path" do
      visit nqt_job_alerts_path
      click_on I18n.t("buttons.subscribe")
      expect(page).to have_current_path(invalid_recaptcha_path(form_name: "jobseekers/nqt_job_alerts_form"))
    end
  end
end
