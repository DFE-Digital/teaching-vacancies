require "rails_helper"

RSpec.describe "Jobseekers can manage their profile" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_profile_path
  end

  describe "changing the jobseekers's profile" do
    let(:profile) { create(:jobseeker_profile, jobseeker_id: jobseeker.id) }
    let(:jobseeker_about_you) { "I am an amazing teacher" }

    it "allows the jobseeker to edit their about you text" do
      click_link("Add details about you")

      fill_in "jobseekers_profile_about_you_form[about_you]", with: jobseeker_about_you
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content(jobseeker_about_you)

      click_link I18n.t("buttons.return_to_profile")
      expect(page).to have_content(jobseeker_about_you)
    end
  end

  describe "changing the jobseekers's profile with max words error" do
    let(:profile) { create(:jobseeker_profile, jobseeker_id: jobseeker.id) }
    let(:jobseeker_about_you) { Faker::Lorem.sentence(word_count: 1001) }

    it "allows the jobseeker to edit their about you text" do
      click_link("Add details about you")

      fill_in "jobseekers_profile_about_you_form[about_you]", with: jobseeker_about_you
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_css(".govuk-form-group--error")
    end
  end
end
