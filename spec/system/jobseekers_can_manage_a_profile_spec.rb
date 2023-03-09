require "rails_helper"

RSpec.describe "Jobseekers can manage their profile" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  describe "changing personal details" do
    let(:profile) { create(:jobseeker_profile, jobseeker:) }

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
        within "#personal_details" do
          click_link "Change", match: :first
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

  describe "personal details if the jobseeker has a previous job application" do
    let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:) }

    before { visit jobseekers_profile_path }

    it "prefills the form with the jobseeker's personal details" do
      expect(page).to have_content(previous_application.first_name)
      expect(page).to have_content(previous_application.last_name)
      expect(page).to have_content(previous_application.phone_number)
    end

    it "adds a notice to inform the user" do
      expect(page).to have_content("your details have been imported into your profile")
    end
  end

  describe "#about_you" do
    let(:jobseeker_about_you) { "I am an amazing teacher" }

    before { visit jobseekers_profile_path }

    it "allows the jobseeker to add #about_you" do
      click_link("Add details about you")

      fill_in "jobseekers_profile_about_you_form[about_you]", with: jobseeker_about_you
      click_on I18n.t("buttons.save_and_continue")

      expect(page).to have_content(jobseeker_about_you)

      click_link I18n.t("buttons.return_to_profile")
      expect(page).to have_content(jobseeker_about_you)
    end
  end

  describe "changing the jobseekers's QTS status" do
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

  describe "QTS if the jobseeker has a previous job application" do
    let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:) }

    it "prefills the form with the jobseeker's personal details" do
      visit jobseekers_profile_path
      expect(page).to have_content("Year QTS awarded#{previous_application.qualified_teacher_status_year}")
    end
  end

  describe "work history" do
    describe "adding an employment history entry to a profile" do
      let!(:profile) { create(:jobseeker_profile, jobseeker:) }

      before { visit jobseekers_profile_path }

      it "associates an 'employment' with their jobseeker profile" do
        expect { add_jobseeker_profile_employment }.to change { profile.employments.count }.by(1)
      end

      context "when the form to add a new employment history entry is submitted" do
        it "redirects to the review page" do
          add_jobseeker_profile_employment

          expect(current_path).to eq(review_jobseekers_profile_work_history_index_path)
        end

        it "displays every employment history entry on the review page" do
          add_jobseeker_profile_employment

          profile.employments.each do |employment|
            expect(page).to have_content(employment.organisation)
            expect(page).to have_content(employment.job_title)
            expect(page).to have_content(employment.started_on.to_formatted_s(:month_year))
            expect(page).to have_content(employment.ended_on.to_formatted_s(:month_year)) unless employment.current_role == "yes"
            expect(page).to have_content(employment.main_duties)
          end
        end
      end
    end

    describe "changing an existing employment history entry" do
      let!(:profile) { create(:jobseeker_profile, jobseeker:) }
      let!(:employment) { create(:employment, :jobseeker_profile_employment, jobseeker_profile: profile) }
      let(:new_employer) { "NASA" }
      let(:new_job_role) { "Chief ET locator" }

      it "successfully changes the employment record" do
        visit jobseekers_profile_path

        within(".govuk-summary-card", match: :first) { click_link I18n.t("buttons.change") }

        expect(current_path).to eq(edit_jobseekers_profile_work_history_path(employment))

        fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.organisation"), with: new_employer
        fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.job_title"), with: new_job_role

        click_on I18n.t("buttons.save_and_continue")

        expect(profile.employments.count).to eq(1)
        expect(profile.employments.first.organisation).to eq(new_employer)
        expect(profile.employments.first.job_title).to eq(new_job_role)
        expect(current_path).to eq(review_jobseekers_profile_work_history_index_path)
      end
    end

    describe "deleting an employment history entry" do
      let!(:profile) { create(:jobseeker_profile, jobseeker:) }
      let!(:employment) { create(:employment, :jobseeker_profile_employment, jobseeker_profile_id: profile.id) }

      it "deletes the employment record" do
        visit review_jobseekers_profile_work_history_index_path

        within(".govuk-summary-card", match: :first) { click_link I18n.t("buttons.delete") }

        expect(profile.employments.any?).to be false
        expect(current_path).to eq(review_jobseekers_profile_work_history_index_path)
      end
    end

    context "if the jobseeker has a previous job application" do
      let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:, create_details: true) }

      it "prefills the form with the jobseeker's work history" do
        visit jobseekers_profile_path
        previous_application.employments.each do |employment|
          expect(page).to have_content(employment.organisation)
        end
      end
    end
  end

  describe "qualifications" do
    context "if the jobseeker has a previous job application" do
      let!(:previous_application) { create(:job_application, :status_submitted, jobseeker:, create_details: true) }

      it "prefills the form with the jobseeker's qualifications" do
        visit jobseekers_profile_path
        previous_application.qualifications.each do |qualification|
          expect(page).to have_content(qualification.name)
        end
      end
    end
  end

  private

  def add_jobseeker_profile_employment
    click_link("Add roles")

    fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.organisation"), with: "Arsenal"
    fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.job_title"), with: "Number 9"
    fill_in "jobseekers_profile_employment_form[started_on(1i)]", with: "1991"
    fill_in "jobseekers_profile_employment_form[started_on(2i)]", with: "09"
    choose "Yes", name: "jobseekers_profile_employment_form[current_role]"
    fill_in I18n.t("helpers.label.jobseekers_profile_employment_form.main_duties"), with: "Goals and that"

    click_on I18n.t("buttons.save_and_continue")
  end
end
