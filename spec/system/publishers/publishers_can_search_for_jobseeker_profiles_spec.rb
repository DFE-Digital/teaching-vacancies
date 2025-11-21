require "rails_helper"

RSpec.describe "Publishers searching for Jobseeker profiles", type: :system do
  let(:publisher) { create(:publisher, organisations: [organisation]) }
  let(:organisation) { create(:school, geopoint: "POINT (-0.108267 51.506438)") }
  let(:school_oxford) { create(:school, name: "Oxford", geopoint: "POINT (-0.108267 51.506438)") }
  let(:school_cambridge) { create(:school, name: "Cambridge", geopoint: "POINT (-0.108267 51.506438)") }
  let(:trust_publisher) { create(:publisher, organisations: [trust]) }
  let(:trust) { create(:trust, schools: [school_oxford, school_cambridge], geopoint: "POINT (-0.108267 51.506438)") }
  let(:roles) do
    %w[ teacher
        headteacher
        deputy_headteacher
        assistant_headteacher
        head_of_year_or_phase
        head_of_department_or_curriculum
        teaching_assistant
        higher_level_teaching_assistant
        education_support
        sendco
        administration_hr_data_and_finance
        catering_cleaning_and_site_management
        it_support
        pastoral_health_and_welfare
        other_leadership
        other_support ]
  end

  let!(:jobseeker_profile) { create(:jobseeker_profile, :with_personal_details, qualified_teacher_status: "yes", qualified_teacher_status_year: "2000", job_preferences: job_preferences, employments: [current_employment]) }
  let(:job_preferences) { create(:job_preferences, roles: roles, key_stages: %w[ks1], working_patterns: %w[full_time], locations: [location_preference_containing_school], subjects: ["English"]) }
  let(:location_preference_containing_school) { create(:job_preferences_location, name: "London", radius: 100) }
  let(:current_employment) { create(:employment, :jobseeker_profile_employment, job_title: "Senior Teacher", started_on: 1.year.ago, ended_on: nil, is_current_role: true) }

  let!(:part_time_jobseeker_profile) { create(:jobseeker_profile, :with_personal_details, qualified_teacher_status: "yes", qualified_teacher_status_year: "2000", job_preferences: part_time_job_preferences) }
  let(:part_time_job_preferences) { create(:job_preferences, roles: %w[teacher], key_stages: %w[ks1], working_patterns: %w[part_time], locations: [part_time_preference_containing_school], subjects: ["Physics"]) }
  let(:part_time_preference_containing_school) { create(:job_preferences_location, name: "London", radius: 100) }

  let!(:no_right_to_work_in_uk_profile) { create(:jobseeker_profile, personal_details: personal_details, qualified_teacher_status: "yes", qualified_teacher_status_year: "2000", job_preferences: no_right_to_work_in_uk_preferences) }
  let(:personal_details) { create(:personal_details, has_right_to_work_in_uk: false) }
  let(:no_right_to_work_in_uk_preferences) { create(:job_preferences, roles: %w[teacher], key_stages: %w[ks1], working_patterns: %w[part_time], locations: [no_right_to_work_in_uk_containing_school], subjects: ["Geography"]) }
  let(:no_right_to_work_in_uk_containing_school) { create(:job_preferences_location, name: "London", radius: 100) }

  let!(:cleaning_staff_jobseeker_profile) { create(:jobseeker_profile, :with_personal_details, qualified_teacher_status: "no", job_preferences: cleaning_staff_job_preferences) }
  let(:cleaning_staff_job_preferences) { create(:job_preferences, roles: %w[catering_cleaning_and_site_management other_support], working_patterns: %w[full_time], locations: [cleaning_staff_location_preference_containing_school]) }
  let(:cleaning_staff_location_preference_containing_school) { create(:job_preferences_location, name: "London", radius: 100) }

  let!(:teaching_assistant_jobseeker_profile) { create(:jobseeker_profile, :with_personal_details, qualified_teacher_status: "no", job_preferences: teaching_assistant_job_preferences) }
  let(:teaching_assistant_job_preferences) { create(:job_preferences, roles: %w[teaching_assistant higher_level_teaching_assistant], working_patterns: %w[full_time], locations: [teaching_assistant_preference_containing_school]) }
  let(:teaching_assistant_preference_containing_school) { create(:job_preferences_location, name: "London", radius: 100) }

  describe "Visiting the publisher's jobseeker profiles start page" do
    before do
      login_publisher(publisher:, organisation:)
      visit publishers_jobseeker_profiles_path
      # wait for page load
      find(".search-results")
    end

    after { logout }

    it "passes a11y", :a11y do
      expect(page).to be_axe_clean
    end

    it "will display all jobseeker profiles with location preference areas containing the school" do
      [jobseeker_profile, part_time_jobseeker_profile].each do |jobseeker_profile|
        expect(page).to have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
        expect(page).to have_content(jobseeker_profile.full_name)
        expect(page).to have_content(
          "Teacher, Headteacher, Deputy headteacher, Assistant headteacher, " \
          "Head of year or phase, Head of department or curriculum, " \
          "Teaching assistant, HLTA (higher level teaching assistant), " \
          "Learning support or cover supervisor, SENDCo (special educational needs and disabilities coordinator), " \
          "Administration, HR, data and finance, " \
          "Catering, cleaning and site management, IT support, " \
          "Pastoral, health and welfare, Other leadership roles, " \
          "Other support roles",
        )
        expect(page).to have_content(jobseeker_profile.job_preferences.key_stages.first.humanize)
        expect(page).to have_content(jobseeker_profile.job_preferences.working_patterns.first.humanize)
        expect(page).to have_content(jobseeker_profile.job_preferences.subjects.first.humanize)
      end

      # Check that current role is displayed for the jobseeker with employment
      within ".search-results__item", text: jobseeker_profile.full_name do
        within ".govuk-summary-list__row", text: "Current role" do
          expect(page).to have_content("Current role")
          expect(page).to have_content(current_employment.job_title)
        end
      end
    end

    it "will allow a publisher to filter the jobseeker profiles" do
      within ".filters-component" do
        check I18n.t("publishers.jobseeker_profiles.filters.working_pattern_options.part_time")
      end

      # Apply filters
      within ".filters-component" do
        first("button").click
      end

      expect(page).to have_link(href: publishers_jobseeker_profile_path(part_time_jobseeker_profile))
      expect(page).to_not have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
    end

    context "when filters are selected" do
      before do
        within ".filters-component" do
          check I18n.t("publishers.jobseeker_profiles.filters.working_pattern_options.part_time")
          check I18n.t("publishers.jobseeker_profiles.filters.key_stage_options.ks5")
          check I18n.t("publishers.jobseeker_profiles.filters.right_to_work_in_uk_options.true")
        end

        # Apply filters
        within ".filters-component" do
          first("button").click
        end

        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(part_time_jobseeker_profile))
        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(no_right_to_work_in_uk_profile))
        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(cleaning_staff_jobseeker_profile))
        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(teaching_assistant_jobseeker_profile))
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
        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(cleaning_staff_jobseeker_profile))
        expect(page).to_not have_link(href: publishers_jobseeker_profile_path(teaching_assistant_jobseeker_profile))
        expect(page).to have_link(I18n.t("publishers.jobseeker_profiles.filters.working_pattern_options.part_time"))
        expect(page).not_to have_link(I18n.t("publishers.jobseeker_profiles.filters.key_stage_options.ks5"))
        expect(page).not_to have_link(I18n.t("publishers.jobseeker_profiles.filters.right_to_work_in_uk_options.true"))
      end

      it "will allow publisher to clear all filters" do
        click_link "Clear filters"

        expect(page).to have_link(href: publishers_jobseeker_profile_path(part_time_jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(no_right_to_work_in_uk_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(cleaning_staff_jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(teaching_assistant_jobseeker_profile))
        expect(page).not_to have_link(I18n.t("publishers.jobseeker_profiles.filters.working_pattern_options.part_time"))
        expect(page).not_to have_link(I18n.t("publishers.jobseeker_profiles.filters.key_stage_options.ks5"))
        expect(page).not_to have_link(I18n.t("publishers.jobseeker_profiles.filters.right_to_work_in_uk_options.true"))
      end
    end

    context "when role filters are selected" do
      it "will allow hiring staff to filter by jobseekers' preferred roles" do
        within ".filters-component" do
          find('span[title="Support"]').click
          check "Catering, cleaning and site management"
          check "HLTA (higher level teaching assistant)"
          # Apply filters
          first("button").click
        end

        expect(page).not_to have_link(href: publishers_jobseeker_profile_path(part_time_jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
        expect(page).not_to have_link(href: publishers_jobseeker_profile_path(no_right_to_work_in_uk_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(cleaning_staff_jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(teaching_assistant_jobseeker_profile))
        expect(page).to have_link("Catering, cleaning and site management")
        expect(page).to have_link("HLTA (higher level teaching assistant)")

        click_link "HLTA (higher level teaching assistant)"

        within ".filters-component" do
          find('span[title="Teaching & leadership"]').click
          check "Teacher"
          # Apply filters
          first("button").click
        end

        expect(page).to have_link(href: publishers_jobseeker_profile_path(part_time_jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(no_right_to_work_in_uk_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(cleaning_staff_jobseeker_profile))
        expect(page).not_to have_link(href: publishers_jobseeker_profile_path(teaching_assistant_jobseeker_profile))
        expect(page).to have_link("Catering, cleaning and site management")
        expect(page).to have_link("Teacher")

        click_link "Clear filters"

        expect(page).to have_link(href: publishers_jobseeker_profile_path(part_time_jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(no_right_to_work_in_uk_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(cleaning_staff_jobseeker_profile))
        expect(page).to have_link(href: publishers_jobseeker_profile_path(teaching_assistant_jobseeker_profile))
      end
    end
  end

  context "when organisation is a trust" do
    before do
      login_publisher(publisher: trust_publisher, organisation: trust)
      visit publishers_jobseeker_profiles_path
    end

    after { logout }

    context "when no locations are selected in the filters" do
      it "shows text explaining that the candidates are willing travel to one of more of the locations" do
        expect(page).to have_selector("p", text: "These candidates are willing to travel to a location that's near to at least one of your schools.")
      end
    end

    context "when 1 location is selected in the filters" do
      it "shows text explaining that the candidates are willing travel to the selected location" do
        check "Oxford"
        # Apply filters
        within ".filters-component" do
          first("button").click
        end
        expect(page).to have_selector("p", text: "These candidates are willing to travel to your selected school location.")
      end
    end

    context "when multiple locations are selected in the filters" do
      it "shows text explaining that the candidates are willing travel to at least one of the selected locations" do
        check "Oxford"
        check "Cambridge"
        # Apply filters
        within ".filters-component" do
          first("button").click
        end
        expect(page).to have_selector("p", text: "These candidates are willing to travel to at least one of your selected school locations.")
      end
    end
  end

  context "when organisation is not a trust" do
    before do
      login_publisher(publisher:, organisation:)
      visit publishers_jobseeker_profiles_path
    end

    after { logout }

    it "shows text explaining that the candidates are willing to travel to the school" do
      expect(page).to have_selector("p", text: "These candidates are willing to travel to a location that’s near to your school.")
    end
  end
end
