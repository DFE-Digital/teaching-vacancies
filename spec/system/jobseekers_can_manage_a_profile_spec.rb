require "rails_helper"

RSpec.describe "Jobseekers can manage their profile" do
  let(:jobseeker) { create(:jobseeker) }

  before do
    login_as(jobseeker, scope: :jobseeker)
  end

  it "allows the jobseeker to navigate to their profile" do
    visit jobseeker_root_path

    within "#navigation" do
      expect(page).to have_content("Your profile")
      click_on "Your profile"
    end

    expect(page).to have_current_path(jobseekers_profile_path)
  end

  describe "changing personal details" do
    let(:profile) { create(:jobseeker_profile, :with_personal_details, jobseeker:) }

    context "when filling in the profile for the first time" do
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

      it "does not a notice to inform the user about prefilling" do
        expect(page).not_to have_content("your details have been imported into your profile")
      end
    end

    context "when editing a profile that has already been completed" do
      let(:new_first_name) { "Samwise" }
      let(:new_last_name) { "Gamgee" }
      let(:old_phone_number) { "07777777777" }

      before do
        profile.personal_details.update!(
          first_name: "Frodo",
          last_name: "Baggins",
          phone_number_provided: true,
          phone_number: old_phone_number,
          completed_steps: { "name" => "completed", "phone_number" => "completed" },
        )

        visit jobseekers_profile_path
      end

      it "allows the jobseeker to edit their profile" do
        row = page.find(".govuk-summary-list__key", text: "First name").find(:xpath, "..")

        within(row) do
          click_link "Change"
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

  describe "personal details if the jobseeker has a blank previous job application" do
    let!(:previous_application) { create(:job_application, :status_draft, jobseeker:, first_name: nil, last_name: nil, phone_number: "01234567890") }

    before { visit jobseekers_profile_path }

    it "prefills the form with the jobseeker's provided personal details" do
      expect(page).to have_content(previous_application.phone_number)
    end

    it "still shows the summary rows for the blank attributes" do
      expect(page).to have_content("First name")
      expect(page).to have_content("Last name")
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

  describe "toggling on and off" do
    let(:publisher) { organisation.publishers.first }

    let(:organisation) do
      create(:school,
             publishers: [build(:publisher)],
             geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(*bexleyheath))
    end

    let(:bexleyheath) { %w[0.14606549011864176 51.457814649098104] }

    let!(:profile) { create(:jobseeker_profile, jobseeker:, job_preferences:, active: false) }

    let(:job_preferences) do
      build(:job_preferences,
            jobseeker_profile: nil,
            locations: build_list(:job_preferences_location, 1, radius: 200, job_preferences: nil))
    end

    before do
      allow(Geocoding).to receive(:test_coordinates).and_return(bexleyheath)
      login_publisher(publisher:)
    end

    context "if the profile does not exist" do
      let!(:profile) { nil }

      it "does not appear in search results" do
        visit publishers_jobseeker_profiles_path
        expect(page).not_to have_css(".search-results__item")
      end
    end

    context "if the profile is inactive" do
      let!(:profile) { create(:jobseeker_profile, jobseeker:, job_preferences:, active: false) }

      it "does not appear in search results" do
        visit publishers_jobseeker_profiles_path
        expect(page).not_to have_content(profile.full_name)
      end
    end

    context "when profile contains minimum information required for publishing" do
      let!(:profile) do
        create(:jobseeker_profile, :with_personal_details, :with_job_preferences,
               job_preferences:,
               jobseeker:,
               active: false)
      end

      it "can be toggled on and off" do
        visit jobseekers_profile_path

        expect(page).to have_content(I18n.t("jobseekers.profiles.show.preview_and_turn_on_profile"))
        expect(page).not_to have_css(".govuk-tag", text: I18n.t("jobseekers.profiles.show.active"))

        visit publishers_jobseeker_profiles_path
        expect(page).not_to have_content(profile.full_name)

        visit jobseekers_profile_path
        within ".preview-and-turn-on-profile" do
          click_link I18n.t("jobseekers.profiles.show.turn_on_profile")
        end

        click_button I18n.t("jobseekers.profiles.show.turn_on_profile")
        expect(page).to have_content(I18n.t("jobseekers.profiles.show.profile_turned_on"))
        expect(page).to have_css(".govuk-tag", text: I18n.t("jobseekers.profiles.show.active"))
        expect(page).to have_link(I18n.t("jobseekers.profiles.show.turn_off_profile"))

        visit publishers_jobseeker_profiles_path
        expect(page).to have_content(profile.full_name)

        visit jobseekers_profile_path
        within ".preview-and-turn-on-profile" do
          click_link I18n.t("jobseekers.profiles.show.turn_off_profile")
        end

        click_button I18n.t("jobseekers.profiles.show.turn_off_profile")
        expect(page).to have_content(I18n.t("jobseekers.profiles.show.profile_turned_off"))
        expect(page).not_to have_css(".govuk-tag", text: I18n.t("jobseekers.profiles.show.active"))
        expect(page).to have_link(I18n.t("jobseekers.profiles.show.turn_on_profile"))

        visit publishers_jobseeker_profiles_path
        expect(page).not_to have_content(profile.full_name)

        visit publishers_jobseeker_profile_path(profile)
        expect(page).to have_content("Page not found")
      end
    end

    context "when profile does not contain minimum information required for publishing" do
      let!(:profile) do
        create(:jobseeker_profile, %i[with_personal_details with_job_preferences].sample,
               jobseeker:,
               active: false)
      end

      it "cannot be toggled on" do
        visit jobseekers_profile_path

        expect(page).to have_content(I18n.t("jobseekers.profiles.show.preview_and_turn_on_profile"))
        expect(page).not_to have_css(".govuk-tag", text: I18n.t("jobseekers.profiles.show.active"))

        within ".preview-and-turn-on-profile" do
          click_link I18n.t("jobseekers.profiles.show.turn_on_profile")
        end

        expect(page).to have_content I18n.t("jobseekers.profiles.toggle.not_ready")
      end
    end
  end

  describe "hiding profile from specific organisations" do
    let(:bexleyheath) { ["0.14606549011864176", "51.457814649098104"] }

    let(:bexleyheath_geopoint) do
      RGeo::Geographic.spherical_factory(srid: 4326).point(*bexleyheath)
    end

    let!(:permitted_organisation) do
      create(:school,
             name: "Permitted School",
             publishers: [permitted_publisher],
             geopoint: bexleyheath_geopoint)
    end

    let!(:forbidden_organisation) do
      create(:school,
             name: "Forbidden School",
             publishers: [forbidden_publisher],
             geopoint: bexleyheath_geopoint)
    end

    let(:permitted_publisher) { create(:publisher) }
    let(:forbidden_publisher) { create(:publisher) }

    let!(:profile) { create(:jobseeker_profile, jobseeker:, job_preferences:, active: true) }

    let(:job_preferences) do
      build(:job_preferences,
            jobseeker_profile: nil,
            locations: build_list(:job_preferences_location, 1, radius: 200, job_preferences: nil))
    end

    before do
      allow(Geocoding).to receive(:test_coordinates).and_return(bexleyheath)
    end

    it "allows the jobseeker hiding themselves from specific schools", js: true do
      login_publisher(publisher: permitted_publisher)
      visit publishers_jobseeker_profiles_path
      expect(page).to have_content(profile.full_name)

      login_publisher(publisher: forbidden_publisher)
      visit publishers_jobseeker_profiles_path
      expect(page).to have_content(profile.full_name)

      visit jobseekers_profile_path
      click_on I18n.t("jobseekers.profiles.show.set_up_profile_visibility")
      choose "Yes", visible: false
      click_on I18n.t("buttons.save_and_continue")

      field = find_field("Name of school or trust")
      field.fill_in(with: forbidden_organisation.name)
      field.native.send_keys(:tab)
      click_on I18n.t("buttons.save_and_continue")

      login_publisher(publisher: forbidden_publisher)
      visit publishers_jobseeker_profiles_path
      expect(page).not_to have_content(profile.full_name)

      login_publisher(publisher: permitted_publisher)
      visit publishers_jobseeker_profiles_path
      expect(page).to have_content(profile.full_name)

      visit jobseekers_profile_path
      click_on I18n.t("jobseekers.profiles.hide_profile.summary.add_a_school")

      field = find_field("Name of school or trust")
      field.fill_in(with: permitted_organisation.name)
      field.native.send_keys(:tab)
      click_on I18n.t("buttons.save_and_continue")

      login_publisher(publisher: permitted_publisher)
      visit publishers_jobseeker_profiles_path
      expect(page).not_to have_content(profile.full_name)

      login_publisher(publisher: forbidden_publisher)
      visit publishers_jobseeker_profiles_path
      expect(page).not_to have_content(profile.full_name)

      visit publishers_jobseeker_profile_path(profile)
      expect(page).to have_content("Page not found")

      visit schools_jobseekers_profile_hide_profile_path
      within page.find(".govuk-summary-list__key", text: permitted_organisation.name).find(:xpath, "..") do
        click_on I18n.t("buttons.delete")
      end
      click_button I18n.t("jobseekers.profiles.hide_profile.delete.delete_school")

      login_publisher(publisher: permitted_publisher)
      visit publishers_jobseeker_profiles_path
      expect(page).to have_content(profile.full_name)

      login_publisher(publisher: forbidden_publisher)
      visit publishers_jobseeker_profiles_path
      expect(page).not_to have_content(profile.full_name)
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
