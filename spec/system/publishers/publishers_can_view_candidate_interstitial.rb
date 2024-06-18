require "rails_helper"

RSpec.describe "Publishers can see the Candidate profiles interstitial page" do
  let(:school) { create(:school) }

  context "the user has logged in for the first time" do
    let(:publisher) { create(:publisher, acknowledged_candidate_profiles_interstitial: false, accepted_terms_at: nil) }

    before { login_publisher(publisher: publisher, organisation: school) }

    it "they will see the interstitial page" do
      visit organisation_jobs_with_type_path

      check I18n.t("terms_and_conditions.label")
      click_on I18n.t("buttons.accept_and_continue")

      expect(page).to have_content("You can now view candidate profiles and invite them to apply to jobs")
    end
  end

  context "the user has logged in for the second time" do
    let(:publisher) { create(:publisher, acknowledged_candidate_profiles_interstitial: true, accepted_terms_at: Time.current) }

    before { login_publisher(publisher: publisher, organisation: school) }

    it "they will NOT see the interstitial page" do
      visit organisation_jobs_with_type_path

      expect(page).to have_no_content("You can now view candidate profiles and invite them to apply to jobs")
    end
  end
end
