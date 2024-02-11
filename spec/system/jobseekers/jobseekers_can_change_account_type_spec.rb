require "rails_helper"

RSpec.describe "Jobseekers can change account type" do
  let(:jobseeker) { create(:jobseeker, email: "old@example.net", password: "password", account_type: "teaching") }
  let(:created_jobseeker) { Jobseeker.first }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit edit_jobseeker_registration_path(account_type_update: true)
  end

  describe "updating account type and confirming change" do
    it "validates and submits the form and updates the jobseekers account type" do
      fill_in "jobseeker[current_password]", with: "incorrect"
      choose "Non-teaching support jobs"
      click_on I18n.t("buttons.continue")

      expect(page).to have_css("h2", text: "There is a problem")
      expect(page).to have_css(".govuk-error-summary__body .govuk-error-summary__list", text: "Your password is incorrect")

      expect(created_jobseeker.reload.account_type).to eq("teaching")

      fill_in "jobseeker[current_password]", with: jobseeker.password
      choose "Non-teaching support jobs"
      click_on I18n.t("buttons.continue")

      expect(created_jobseeker.reload.account_type).to eq("non_teaching")
      expect(current_path).to eq(jobseekers_account_path)

      within "div#account_type.govuk-summary-list__row" do
        expect(page).to have_css("dt.govuk-summary-list__key", text: "Account type")
        expect(page).to have_css("dd.govuk-summary-list__value", text: "Non-teaching")
      end
    end
  end
end
