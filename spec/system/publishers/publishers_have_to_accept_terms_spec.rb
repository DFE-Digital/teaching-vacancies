require "rails_helper"

RSpec.describe "Publishers can accept terms and conditions" do
  let(:school) { create(:school) }

  context "the user has not accepted the terms and conditions" do
    let(:publisher) { create(:publisher, accepted_terms_at: nil) }

    before { login_publisher(publisher: publisher, organisation: school) }

    it "they will see the terms and conditions" do
      visit organisation_jobs_with_type_path

      expect(page).to have_content(I18n.t("terms_and_conditions.please_accept"))
    end

    it "they can accept the terms and conditions" do
      visit publishers_terms_and_conditions_path

      expect(publisher).not_to be_accepted_terms_at

      check I18n.t("terms_and_conditions.label")
      click_on I18n.t("buttons.accept_and_continue")

      publisher.reload
      expect(page).to have_content("You can now view candidate profiles and invite them to apply to jobs")
      expect(publisher).to be_accepted_terms_at
    end

    it "an error is shown if they don’t accept" do
      visit publishers_terms_and_conditions_path

      expect(publisher).not_to be_accepted_terms_at

      click_on I18n.t("buttons.accept_and_continue")

      publisher.reload

      expect(page).to have_content("There is a problem")
      expect(publisher).not_to be_accepted_terms_at
    end

    context "signing out" do
      it "with authentication fallback" do
        allow(AuthenticationFallback).to receive(:enabled?).and_return(true)

        visit publishers_terms_and_conditions_path
        click_on(I18n.t("nav.sign_out"))

        within(".govuk-header__navigation") { expect(page).to have_content(I18n.t("buttons.sign_in")) }
      end

      it "without authentication fallback" do
        allow(AuthenticationFallback).to receive(:enabled?).and_return(false)

        visit publishers_terms_and_conditions_path

        click_on(I18n.t("nav.sign_out"))

        expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
      end
    end
  end

  context "the user has accepted the terms and conditions" do
    let(:publisher) { create(:publisher, accepted_terms_at: Time.current) }

    before { login_publisher(publisher: publisher, organisation: school) }

    it "they will not see the terms and conditions" do
      visit organisation_jobs_with_type_path

      expect(page).to have_no_content(I18n.t("terms_and_conditions.please_accept"))
    end
  end
end
