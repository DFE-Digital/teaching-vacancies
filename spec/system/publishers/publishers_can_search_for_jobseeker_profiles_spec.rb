require "rails_helper"

RSpec.describe "Publishers searching for Jobseeker profiles", type: :system do
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:organisation) { create(:school, geopoint: "POINT (-0.108267 51.506438)") }
  let(:school_oxford) { create(:school, name: "Oxford", geopoint: "POINT (-0.108267 51.506438)") }
  let(:school_cambridge) { create(:school, name: "Cambridge", geopoint: "POINT (-0.108267 51.506438)") }
  let(:trust_publisher) { create(:publisher, organisations: [trust]) }
  let(:trust) { create(:trust, schools: [school_oxford, school_cambridge], geopoint: "POINT (-0.108267 51.506438)") }

  let!(:jobseeker_profile) { create(:jobseeker_profile, :with_personal_details, qualified_teacher_status: "yes", qualified_teacher_status_year: "2000", job_preferences: job_preferences) }
  let(:job_preferences) { create(:job_preferences, roles: %w[teacher], key_stages: %w[ks1], working_patterns: %w[full_time], locations: [location_preference_containing_school]) }
  let(:location_preference_containing_school) { create(:job_preferences_location, name: "London", radius: 100) }

  let!(:part_time_jobseeker_profile) { create(:jobseeker_profile, :with_personal_details, qualified_teacher_status: "yes", qualified_teacher_status_year: "2000", job_preferences: part_time_job_preferences) }
  let(:part_time_job_preferences) { create(:job_preferences, roles: %w[teacher], key_stages: %w[ks1], working_patterns: %w[part_time], locations: [part_time_preference_containing_school]) }
  let(:part_time_preference_containing_school) { create(:job_preferences_location, name: "London", radius: 100) }

  let!(:no_right_to_work_in_uk_profile) { create(:jobseeker_profile, personal_details: personal_details, qualified_teacher_status: "yes", qualified_teacher_status_year: "2000", job_preferences: no_right_to_work_in_uk_preferences) }
  let(:personal_details) { create(:personal_details, right_to_work_in_uk: false) }
  let(:no_right_to_work_in_uk_preferences) { create(:job_preferences, roles: %w[teacher], key_stages: %w[ks1], working_patterns: %w[part_time], locations: [no_right_to_work_in_uk_containing_school]) }
  let(:no_right_to_work_in_uk_containing_school) { create(:job_preferences_location, name: "London", radius: 100) }

  describe "Visiting the publisher's jobseeker profiles start page" do
    before { login_publisher(publisher:, organisation:) }
    context "when user is not a MAT" do
    end
    it "will display all jobseeker profiles with location preference areas containing the school" do
      visit publishers_jobseeker_profiles_path

      [jobseeker_profile, part_time_jobseeker_profile].each do |jobseeker_profile|
        expect(page).to have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
        expect(page).to have_content(jobseeker_profile.full_name)
        expect(page).to have_content(jobseeker_profile.job_preferences.roles.first.humanize)
        expect(page).to have_content(jobseeker_profile.job_preferences.key_stages.first.humanize)
        expect(page).to have_content(jobseeker_profile.job_preferences.working_patterns.first.humanize)
      end
    end

    it "will allow a publisher to filter the jobseeker profiles" do
      visit publishers_jobseeker_profiles_path

      within ".filters-component" do
        check I18n.t("publishers.jobseeker_profiles.filters.working_pattern_options.part_time")
      end

      within ".filters-component" do
        click_on I18n.t("buttons.apply_filters")
      end

      expect(page).to have_link(href: publishers_jobseeker_profile_path(part_time_jobseeker_profile))
      expect(page).to_not have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
    end

    context "when filters are selected" do
      before do
        visit publishers_jobseeker_profiles_path

        within ".filters-component" do
          check I18n.t("publishers.jobseeker_profiles.filters.working_pattern_options.part_time")
          check I18n.t("publishers.jobseeker_profiles.filters.key_stage_options.ks5")
          check I18n.t("publishers.jobseeker_profiles.filters.right_to_work_in_uk_options.true")
        end

        within ".filters-component" do
          click_on I18n.t("buttons.apply_filters")
        end

        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(part_time_jobseeker_profile))
        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(no_right_to_work_in_uk_profile))
        expect(page).to have_link(I18n.t("publishers.jobseeker_profiles.filters.working_pattern_options.part_time"))
        expect(page).to have_link(I18n.t("publishers.jobseeker_profiles.filters.key_stage_options.ks5"))
        expect(page).to have_link(I18n.t("publishers.jobseeker_profiles.filters.right_to_work_in_uk_options.true"))
      end

      it "will allow publisher to clear a filter" do
        click_link I18n.t("publishers.jobseeker_profiles.filters.key_stage_options.ks5")
        click_link I18n.t("publishers.jobseeker_profiles.filters.right_to_work_in_uk_options.true")

        expect(page).to have_link(href: publishers_jobseeker_profile_path(part_time_jobseeker_profile))
        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(no_right_to_work_in_uk_profile))
        expect(page).to have_link(I18n.t("publishers.jobseeker_profiles.filters.working_pattern_options.part_time"))
        expect(page).not_to have_link(I18n.t("publishers.jobseeker_profiles.filters.key_stage_options.ks5"))
        expect(page).not_to have_link(I18n.t("publishers.jobseeker_profiles.filters.right_to_work_in_uk_options.true"))
      end

      it "will allow publisher to clear all filters" do
        click_link "Clear filters"

        expect(page).to have_link(href: publishers_jobseeker_profile_path(part_time_jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(no_right_to_work_in_uk_profile))
        expect(page).not_to have_link(I18n.t("publishers.jobseeker_profiles.filters.working_pattern_options.part_time"))
        expect(page).not_to have_link(I18n.t("publishers.jobseeker_profiles.filters.key_stage_options.ks5"))
        expect(page).not_to have_link(I18n.t("publishers.jobseeker_profiles.filters.right_to_work_in_uk_options.true"))
      end
    end
  end

  context "when organisation is a trust" do
    before do 
      login_publisher(publisher: trust_publisher, organisation: trust)
      visit publishers_jobseeker_profiles_path
    end

    context "when no locations are selected in the filters" do
      it "shows text explaining that the candidates are willing travel to one of more of the locations" do
        expect(page).to have_selector('p', text: "These candidates are willing to travel to a locations that's near at least one of your schools.")
      end
    end

    context "when locations are selected in the filters" do
      it "shows text explaining that the candidates are willing travel to selected locations" do
        check "Oxford"
        click_button "Apply filters"
        expect(page).to have_selector('p', text: "These candidates are willing to travel to your selected school locations.")
      end
    end
  end

  context "when organisation is not a trust" do
    before do 
      login_publisher(publisher:, organisation:)
      visit publishers_jobseeker_profiles_path
    end

    it "shows text explaining that the candidates are willing to travel to the school" do
      expect(page).to have_selector('p', text: "These candidates are willing to travel to a location that’s near to your school.")
    end
  end
end
