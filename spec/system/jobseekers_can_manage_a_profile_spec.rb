require "rails_helper"

RSpec.describe "Jobseekers can manage their profile" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_profile_path
  end

  describe "changing the jobseekers's about you" do
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

  describe "changing the jobseekers's QTS status" do
    let(:profile) { create(:jobseeker_profile, jobseeker_id: jobseeker.id) }

    it "allows the jobseeker to edit their QTS status to yes with year acheived" do
      click_link("Add qualified teacher status")

      choose "Yes"
      fill_in "jobseekers_profile_qualified_teacher_status_form[qualified_teacher_status_year]", with: "2019"
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content("2019")
    end

    it "allows the jobseeker to edit their QTS status to no" do
      click_link("Add qualified teacher status")

      choose "I’m on track to receive QTS"
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content("I’m on track to receive QTS")
      expect(page).not_to have_content("2019")
    end
  end
end
