require "rails_helper"

RSpec.describe "Jobseekers can manage their job preferences", :geocode do
  let(:jobseeker) { create(:jobseeker) }
  let(:bexleyheath) { %w[0.14606549011864176 51.457814649098104] }
  let(:organisation) do
    create(:school,
           publishers: [build(:publisher)],
           geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(*bexleyheath))
  end
  let(:publisher) { organisation.publishers.first }

  let(:profile) { create(:jobseeker_profile, :with_personal_details, jobseeker:) }

  before do
    login_as(jobseeker, scope: :jobseeker)
    visit jobseekers_profile_path
    click_link("Add job preferences")
  end

  after { logout }

  context "when just filling in roles" do
    it "displays an incomplete summary" do
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:roles), ignore_query: true)

      check "Head of year or phase"
      check "Assistant headteacher"
      click_on I18n.t("buttons.save_and_continue")
      click_on I18n.t("buttons.cancel")
      expect(page).to have_content("You must complete your job preferences before you turn on your profile.")
      expect(page).to have_link("Complete job preferences", href: jobseekers_job_preferences_step_path(:phases))
    end
  end

  it "allows the jobseeker to fill in their job preferences", :vcr do
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:roles), ignore_query: true)
    expect(page).to have_css("h1", text: "What roles are you interested in?")
    expect(page).to have_css("h2", text: "Teaching")
    expect(page).to have_css("h2", text: "Support")

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:roles), ignore_query: true)
    expect(page).to have_css("h2", text: "There is a problem")

    check "Head of year or phase"
    check "Assistant headteacher"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:phases), ignore_query: true)
    within "h3" do
      expect(page).to have_content("Education phase")
    end

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:phases), ignore_query: true)
    expect(page).to have_css("h2", text: "There is a problem")

    check "Secondary"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:key_stages), ignore_query: true)
    within "h3" do
      expect(page).to have_content("Key stages")
    end

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:key_stages), ignore_query: true)
    expect(page).to have_css("h2", text: "There is a problem")

    check "Key stage 3"
    check "Key stage 4"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:subjects), ignore_query: true)
    within "h3" do
      expect(page).to have_content("Subjects (optional)")
    end

    # Can move forward without selecting any subject
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:working_patterns), ignore_query: true)
    within "h1" do
      expect(page).to have_content("Working patterns")
    end

    # Fill in the Subjects
    click_link "Back"
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:subjects), ignore_query: true)
    within "h3" do
      expect(page).to have_content("Subjects (optional)")
    end

    check "Mathematics"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:working_patterns), ignore_query: true)
    within "h1" do
      expect(page).to have_content("Working patterns")
    end

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:working_patterns), ignore_query: true)

    check "Full time"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(new_jobseekers_job_preferences_location_path, ignore_query: true)
    within "h1" do
      expect(page).to have_content("Location")
    end

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_locations_path, ignore_query: true)
    expect(page).to have_css("h2", text: "There is a problem")

    fill_in "Location", with: "London"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_locations_path, ignore_query: true)
    expect(page).to have_css("h2", text: "There is a problem")

    choose "1 mile"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_locations_path, ignore_query: true)
    within "h1" do
      expect(page).to have_content("Locations")
    end
    expect(page).to have_content("London (1 mile)")

    click_link "Change"
    within "h1" do
      expect(page).to have_content("Location")
    end
    expect(page).to have_field("Location", with: "London")
    expect(page).to have_checked_field("1 mile")

    fill_in "Location", with: "San Francisco"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("h2", text: "There is a problem")

    fill_in "Location", with: "Birmingham"
    choose "5 miles"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_locations_path, ignore_query: true)
    within "h1" do
      expect(page).to have_content("Locations")
    end
    expect(page).to have_content("Birmingham (5 miles)")

    click_link "Delete"
    within "h1" do
      expect(page).to have_content("Confirm that you want to delete Birmingham (5 miles)")
    end
    click_on "Delete this location"

    expect(page).to have_current_path(new_jobseekers_job_preferences_location_path, ignore_query: true)
    expect(page).to have_content("Location deleted")
    within "h1" do
      expect(page).to have_content("Location")
    end

    fill_in "Location", with: "San Francisco"
    choose "1 mile"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("h2", text: "There is a problem")
    expect(page).to have_content("Enter a city, county or postcode in the UK")

    fill_in "Location", with: "London"
    choose "1 mile"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_locations_path, ignore_query: true)
    within "h1" do
      expect(page).to have_content("Locations")
    end
    expect(page).to have_content("London (1 mile)")
    expect(page).to have_css("h2", text: "Do you want to add another location?")

    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_css("h2", text: "There is a problem")

    choose "Yes"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(new_jobseekers_job_preferences_location_path, ignore_query: true)
    within "h1" do
      expect(page).to have_content("Location")
    end

    fill_in "Location", with: "Manchester"
    choose "10 miles"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_locations_path, ignore_query: true)
    within "h1" do
      expect(page).to have_content("Locations")
    end
    expect(page).to have_content("London (1 mile)")
    expect(page).to have_content("Manchester (10 miles)")
    expect(page).to have_css("h2", text: "Do you want to add another location?")

    choose "No"
    click_on I18n.t("buttons.save_and_continue")
    expect(page).to have_current_path(jobseekers_job_preferences_step_path(:review), ignore_query: true)
    expect(page).to have_css("h1", text: "Job preferences")
    expect(page).to have_css("dd", text: "Head of year or phase, Assistant headteacher")
    expect(page).to have_css("dd", text: "Secondary")
    expect(page).to have_css("dd", text: "Key stage 3 (ages 11 to 14), Key stage 4 (ages 14 to 16)")
    expect(page).to have_css("dd", text: "Mathematics")
    expect(page).to have_css("dd", text: "Full time")
    expect(page).to have_content("London (1 mile)")
    expect(page).to have_content("Manchester (10 miles)")

    click_on I18n.t("buttons.return_to_profile")
    expect(page).to have_current_path(jobseekers_profile_path, ignore_query: true)
    expect(page).to have_css("h1", text: "Your profile")
    expect(page).to have_css("dd", text: "Head of year or phase, Assistant headteacher")
    expect(page).to have_css("dd", text: "Secondary")
    expect(page).to have_css("dd", text: "Key stage 3 (ages 11 to 14), Key stage 4 (ages 14 to 16)")
    expect(page).to have_css("dd", text: "Mathematics")
    expect(page).to have_css("dd", text: "Full time")
    expect(page).to have_content("London (1 mile)")
    expect(page).to have_content("Manchester (10 miles)")
  end

  context "when a jobseeker enters non-teacher preferences", :vcr do
    it "changes the journey" do
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:roles), ignore_query: true)
      expect(page).to have_css("h1", text: "What roles are you interested in?")
      expect(page).to have_css("h2", text: "Teaching")
      expect(page).to have_css("h2", text: "Support")

      check "IT support"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:phases), ignore_query: true)
      expect(page).to have_css("h3", text: "Job preferencesEducation phase")

      check "Secondary"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:key_stages), ignore_query: true)
      expect(page).to have_css("h3", text: "Job preferencesKey stages")

      check "I'm not looking for a teaching job"
      click_on I18n.t("buttons.save_and_continue")

      # Can move forward without selecting any subject
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:working_patterns), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesWorking patterns")

      check "Full time"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(new_jobseekers_job_preferences_location_path, ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesLocation")

      fill_in "Location", with: "Manchester"
      choose "10 miles"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_locations_path, ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferencesLocations")
      expect(page).to have_content("Manchester (10 miles)")
      expect(page).to have_css("h2", text: "Do you want to add another location?")

      choose "No"
      click_on I18n.t("buttons.save_and_continue")
      expect(page).to have_current_path(jobseekers_job_preferences_step_path(:review), ignore_query: true)
      expect(page).to have_css("h1", text: "Job preferences")
      expect(page).to have_css("dd", text: "IT support")
      expect(page).to have_css("dd", text: "Secondary")
      expect(page).to have_css("dd", text: "I'm not looking for a teaching job")
      expect(page).to have_css("dd", text: "Full time")
      expect(page).to have_css("dd", text: "Manchester (10 miles)")

      click_on I18n.t("buttons.return_to_profile")
      expect(page).to have_current_path(jobseekers_profile_path, ignore_query: true)
      expect(page).to have_css("h1", text: "Your profile")
      expect(page).to have_css("dd", text: "IT support")
      expect(page).to have_css("dd", text: "Secondary")
      expect(page).to have_css("dd", text: "I'm not looking for a teaching job")
      expect(page).to have_css("dd", text: "Full time")
      expect(page).to have_css("dd", text: "Manchester (10 miles)")
    end
  end
end
