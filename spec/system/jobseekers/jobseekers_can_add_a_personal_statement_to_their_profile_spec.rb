require "rails_helper"

RSpec.describe "Jobseekers can add a personal statement to their profile" do
  let(:jobseeker) { create(:jobseeker) }

  context "with a jobseeker" do
    before { login_as(jobseeker, scope: :jobseeker) }

    after { logout }

    describe "#about_you" do
      let(:jobseeker_about_you) { Faker::Movie.quote }

      before do
        visit edit_jobseekers_profile_about_you_path
      end

      it "allows the jobseeker to add #about_you without JS" do
        expect(page).to have_content("Your personal statement")
        fill_in "jobseeker_profile[about_you]", with: jobseeker_about_you
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content(jobseeker_about_you)

        click_link I18n.t("buttons.return_to_profile")
        expect(page).to have_content(jobseeker_about_you)
      end

      it "allows the jobseeker to add #about_you", :js do
        expect(page).to have_content("Your personal statement")
        fill_in_trix_editor "jobseeker_profile_about_you", with: jobseeker_about_you
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content(jobseeker_about_you)

        click_link I18n.t("buttons.return_to_profile")
        expect(page).to have_content(jobseeker_about_you)
      end
    end
  end
end
