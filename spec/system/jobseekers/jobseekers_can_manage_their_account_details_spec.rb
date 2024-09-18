require "rails_helper"

RSpec.describe "Jobseekers can manage their account details" do
  let(:email_address) { Faker::Internet.email(domain: TEST_EMAIL_DOMAIN) }
  let(:jobseeker) { create(:jobseeker, email: email_address) }

  context "when logged in" do
    before do
      login_as(jobseeker, scope: :jobseeker)
      visit jobseekers_account_path
    end

    after { logout }

    it "shows their account details" do
      within("dl") do
        expect(page).to have_content(I18n.t("jobseekers.accounts.show.summary_list.email"))
        expect(page).to have_content(email_address)
      end
    end
  end

  context "when logged out" do
    before do
      visit jobseekers_account_path
    end

    it "redirects to the sign in page" do
      expect(current_path).to eq(new_jobseeker_session_path)
    end
  end
end
