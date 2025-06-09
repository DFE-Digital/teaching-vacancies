require "rails_helper"

# ok but probably better done as 1 journey - the setup for the second test
# assumes things that are not asserted at the end of the first run.
# minimum test should assert outputs from first run to be fed into second run.
RSpec.describe "Publishers can see the Candidate profiles interstitial page" do
  let(:school) { create(:school) }

  context "the user has logged in for the first time" do
    let(:publisher) { create(:publisher, acknowledged_candidate_profiles_interstitial: false, accepted_terms_at: nil) }

    before { login_publisher(publisher: publisher, organisation: school) }

    after { logout }

    scenario "they will see the interstitial page only once" do
      visit organisation_jobs_with_type_path

      check I18n.t("terms_and_conditions.label")
      click_on I18n.t("buttons.accept_and_continue")

      expect(page).to have_content("You can now view candidate profiles and invite them to apply to jobs")

      visit "/"

      visit organisation_jobs_with_type_path

      expect(page).to_not have_content("You can now view candidate profiles and invite them to apply to jobs")
    end
  end
end
