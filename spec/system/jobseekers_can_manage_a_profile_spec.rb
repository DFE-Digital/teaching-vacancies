require "rails_helper"

RSpec.describe "Jobseekers can manage their profile" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  describe "changing personal details" do
    let(:profile) { create(:jobseeker_profile, jobseeker: jobseeker) }

    context "when filling in the profile for the first time" do
      let(:personal_details) { create(:personal_details, :not_started, jobseeker_profile: profile) }
      let(:first_name) { "Frodo" }
      let(:last_name) { "Baggins" }
      let(:phone_number) { "07777777777" }

      before { visit jobseekers_profile_path }

      it "allows the jobseeker to fill in their personal details" do
        click_link("Add personal details")
        fill_in "personal_details_form[first_name]", with: first_name
        fill_in "personal_details_form[last_name]", with: last_name
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content("Do you want to provide a phone number?")
        choose "Yes"
        fill_in "personal_details_form[phone_number]", with: phone_number
        click_on I18n.t("buttons.save_and_continue")
        click_on I18n.t("buttons.return_to_profile")

        expect(page).to have_content(first_name)
        expect(page).to have_content(last_name)
        expect(page).to have_content(phone_number)
      end
    end

    context "when editing a profile that has already been completed" do
      let!(:personal_details) do
        create(:personal_details,
               jobseeker_profile: profile,
               first_name: "Frodo",
               last_name: "Baggins",
               phone_number_provided: true,
               phone_number: old_phone_number,
               completed_steps: { "name" => "completed", "phone_number" => "completed" })
      end

      let(:new_first_name) { "Samwise" }
      let(:new_last_name) { "Gamgee" }
      let(:old_phone_number) { "07777777777" }

      before { visit jobseekers_profile_path }

      it "allows the jobseeker to edit their profile" do
        within ".govuk-summary-list__row:nth-child(1)" do
          click_on "Change"
        end

        fill_in "personal_details_form[first_name]", with: new_first_name
        fill_in "personal_details_form[last_name]", with: new_last_name
        click_on I18n.t("buttons.save_and_continue")

        choose "No"
        click_on I18n.t("buttons.save_and_continue")

        expect(page).to have_content(new_first_name)
        expect(page).to have_content(new_last_name)
        expect(page).to have_content("No")
        expect(page).not_to have_content(old_phone_number)
      end
    end
  end

  describe "changing the jobseekers's about you" do
    let(:profile) { create(:jobseeker_profile, jobseeker_id: jobseeker.id) }
    let(:jobseeker_about_you) { "I am an amazing teacher" }
    before { visit jobseekers_profile_path }

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
    before { visit jobseekers_profile_path }

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
