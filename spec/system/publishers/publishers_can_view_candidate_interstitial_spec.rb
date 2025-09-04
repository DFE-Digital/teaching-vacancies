require "rails_helper"

RSpec.describe "Publishers can see the Candidate profiles interstitial page" do
  let(:school) { create(:school) }

  before { login_publisher(publisher: publisher, organisation: school) }

  after { logout }

  context "the user has not accepted terms" do
    let(:publisher) { create(:publisher, acknowledged_candidate_profiles_interstitial: false, accepted_terms_at: nil) }

    scenario "they will see the interstitial page only once" do
      visit organisation_jobs_with_type_path

      check I18n.t("terms_and_conditions.label")
      click_on I18n.t("buttons.accept_and_continue")

      expect(page).to have_content("You can now view candidate profiles and invite them to apply to jobs")

      visit organisation_jobs_with_type_path

      expect(page).to_not have_content("You can now view candidate profiles and invite them to apply to jobs")
    end
  end

  context "the user has accepted terms, but somehow has not seen the interstitial" do
    let(:publisher) { create(:publisher, acknowledged_candidate_profiles_interstitial: false) }

    scenario "they will see the interstitial page only once" do
      visit organisation_jobs_with_type_path

      expect(page).to have_current_path publishers_candidate_profiles_interstitial_path

      click_on "View candidate profiles"
      expect(page).to have_current_path publishers_jobseeker_profiles_path
    end
  end
end
