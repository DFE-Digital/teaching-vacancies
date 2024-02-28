require "rails_helper"

RSpec.describe Search::JobseekerProfileSearch do
  subject(:search) { described_class.new(filters) }

  context "when the results are only filtered by organisation" do
    let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], roles: [], working_patterns: [], phases: [], key_stages: [], subjects: [] } }

    context "when the organisation is a school" do
      let(:organisation) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(0.2861, 51.7094)) }

      context "when no job preference area contains the school" do
        it "returns an empty array" do
          expect(search.jobseeker_profiles).to be_empty
        end
      end

      context "when a job preference area contains the school" do
        let(:location_in_london) { [51.5072, -0.1275] }
        let(:london_jobseeker_profile) { create(:jobseeker_profile) }
        let(:london_job_preferences) { create(:job_preferences, jobseeker_profile: london_jobseeker_profile) }
        let!(:london_location_preference) { create(:job_preferences_location, name: "London", radius: 200, job_preferences: london_job_preferences) }

        let(:location_in_manchester) { [53.4807, -2.2426] }
        let(:manchester_jobseeker_profile) { create(:jobseeker_profile) }
        let(:manchester_job_preferences) { create(:job_preferences, jobseeker_profile: manchester_jobseeker_profile) }
        let!(:manchester_location_preference) { create(:job_preferences_location, name: "Manchester", radius: 10, job_preferences: manchester_job_preferences) }

        before { allow(Geocoding).to receive(:test_coordinates).and_return(location_in_london, location_in_manchester) }

        it "returns the jobseeker profiles with preference areas that contain the school" do
          expect(search.jobseeker_profiles).to eq([london_jobseeker_profile])
        end

        it "does not return jobseeker profiles with preference areas that don't contain the school" do
          expect(search.jobseeker_profiles).not_to include(manchester_jobseeker_profile)
        end
      end
    end

    context "when the organisation is a trust" do
      let!(:organisation) { create(:trust, schools: [school1, school2]) }
      let(:location_near_school1) { [51.5538288, -0.1110617] }
      let(:school1) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(-0.1084749, 51.5542907)) }
      let(:location_near_school2) { [51.5080513, -0.1080925] }
      let(:school2) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(-0.1082545, 51.5067853)) }

      before do
        allow(JobPreferences::Location).to receive(:containing).and_call_original
        allow(Geocoding).to receive(:test_coordinates).and_return(location_near_school1, location_near_school2)
      end

      let(:jobseeker_profile) { create(:jobseeker_profile) }
      let(:job_preferences) { create(:job_preferences, jobseeker_profile:) }
      let!(:location_preference_including_school1) { create(:job_preferences_location, name: "N7 7DD", radius: 1, job_preferences:) }

      let(:jobseeker_profile2) { create(:jobseeker_profile) }
      let(:job_preferences2) { create(:job_preferences, jobseeker_profile: jobseeker_profile2) }
      let!(:location_preference_including_school2) { create(:job_preferences_location, name: "SE1 9NA", radius: 1, job_preferences: job_preferences2) }

      it "searches for jobseeker profiles using the location of every individual school within the trust" do
        search.jobseeker_profiles

        expect(JobPreferences::Location).to have_received(:containing).with(school1.geopoint)
        expect(JobPreferences::Location).to have_received(:containing).with(school2.geopoint)
      end

      it "returns every jobseeker profile with a preference area that contains any of their schools" do
        expect(search.jobseeker_profiles).to match_array([jobseeker_profile, jobseeker_profile2])
      end

      context "when filtering jobseeker profiles by the trust's schools" do
        let(:filters) { { current_organisation: organisation, locations: [school1.id], qualified_teacher_status: [], roles: [], working_patterns: [], phases: [], key_stages: [], subjects: [] } }

        it "returns only returns jobseeker profiles with location preferences that contain the selected school" do
          expect(search.jobseeker_profiles).to eq([jobseeker_profile])
        end
      end
    end
  end

  describe "using other jobseeker profile filters" do
    let!(:organisation) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(-0.1084749, 51.5542907)) }
    let(:location_near_organisation) { [51.5538288, -0.1110617] }

    let(:location_preference) { { name: "N7 7DD", radius: 2 } }
    let(:control_jobseeker_profile) { create(:jobseeker_profile, **control_profile_attrs) }
    let(:control_job_preferences) { create(:job_preferences, **control_job_preferences_attrs, jobseeker_profile: control_jobseeker_profile) }
    let!(:control_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: control_job_preferences) }

    before { allow(Geocoding).to receive(:test_coordinates).and_return(location_near_organisation) }

    context "jobseeker_profile qualified_teacher_status" do
      let(:filters) { { current_organisation: organisation, qualified_teacher_status: %w[yes], roles: [], working_patterns: [], phases: [], key_stages: [], subjects: [] } }
      let(:control_profile_attrs) { { qualified_teacher_status: "no" } }
      let(:control_job_preferences_attrs) { {} }

      let(:qts_jobseeker_profile) { create(:jobseeker_profile, qualified_teacher_status: "yes") }
      let(:qts_job_preferences) { create(:job_preferences, jobseeker_profile: qts_jobseeker_profile) }
      let!(:qts_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: qts_job_preferences) }

      it "should return the jobseeker profiles with the qualified_teacher_status specified in the filters" do
        expect(search.jobseeker_profiles).to eq([qts_jobseeker_profile])
      end

      context "searching using multiple QTS statuses" do
        let(:filters) { { current_organisation: organisation, qualified_teacher_status: %w[yes on_track], roles: [], working_patterns: [], phases: [], key_stages: [], subjects: [] } }

        let(:on_track_qts_jobseeker_profile) { create(:jobseeker_profile, qualified_teacher_status: "on_track") }
        let(:on_track_qts_job_preferences) { create(:job_preferences, jobseeker_profile: on_track_qts_jobseeker_profile) }
        let!(:on_track_qts_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: on_track_qts_job_preferences) }

        it "should return the jobseeker profiles with the qualified_teacher_status specified in the filters" do
          expect(search.jobseeker_profiles).to match_array([qts_jobseeker_profile, on_track_qts_jobseeker_profile])
        end
      end
    end

    context "job_preferences roles" do
      let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], teaching_job_roles: [], teaching_support_job_roles: [], non_teaching_support_job_roles: %w[other_support], working_patterns: [], phases: [], key_stages: [], subjects: [] } }
      let(:control_job_preferences_attrs) { { roles: %w[leader] } }
      let(:control_profile_attrs) { {} }

      let!(:teacher_jobseeker_profile) { create(:jobseeker_profile) }
      let(:teacher_job_preferences) { create(:job_preferences, roles: %w[teacher], jobseeker_profile: teacher_jobseeker_profile) }
      let!(:teacher_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: teacher_job_preferences) }

      let!(:cleaning_staff_jobseeker_profile) { create(:jobseeker_profile, :with_personal_details, qualified_teacher_status: "no", job_preferences: cleaning_staff_job_preferences) }
      let(:cleaning_staff_job_preferences) { create(:job_preferences, roles: %w[catering_cleaning_and_site_management other_support], working_patterns: %w[full_time], locations: [cleaning_staff_location_preference_containing_school]) }
      let(:cleaning_staff_location_preference_containing_school) { create(:job_preferences_location, name: "London", radius: 100) }

      let!(:teaching_assistant_jobseeker_profile) { create(:jobseeker_profile, :with_personal_details, qualified_teacher_status: "no", job_preferences: teaching_assistant_job_preferences) }
      let(:teaching_assistant_job_preferences) { create(:job_preferences, roles: %w[teaching_assistant higher_level_teaching_assistant], working_patterns: %w[full_time], locations: [teaching_assistant_preference_containing_school]) }
      let(:teaching_assistant_preference_containing_school) { create(:job_preferences_location, name: "London", radius: 100) }

      it "should only return the jobseeker profiles with the roles specified in the filters" do
        expect(search.jobseeker_profiles).to eq([cleaning_staff_jobseeker_profile])
      end

      context "searching using multiple roles" do
        let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], teaching_job_roles: %w[teacher headteacher], teaching_support_job_roles: [], non_teaching_support_job_roles: [], working_patterns: [], phases: [], key_stages: [], subjects: [] } }

        let(:headteacher_jobseeker_profile) { create(:jobseeker_profile) }
        let(:headteacher_job_preferences) { create(:job_preferences, roles: %w[headteacher], jobseeker_profile: headteacher_jobseeker_profile) }
        let!(:headteacher_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: headteacher_job_preferences) }

        it "should return the jobseeker profiles with the roles specified in the filters" do
          expect(search.jobseeker_profiles).to match_array([teacher_jobseeker_profile, headteacher_jobseeker_profile])
        end
      end
    end

    context "job_preferences working_patterns" do
      let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], roles: [], working_patterns: %w[full_time], phases: [], key_stages: [], subjects: [] } }
      let(:control_job_preferences_attrs) { { working_patterns: %w[made_up_working_pattern] } }
      let(:control_profile_attrs) { {} }

      let!(:full_time_jobseeker_profile) { create(:jobseeker_profile, job_preferences: full_time_job_preferences) }
      let(:full_time_job_preferences) { create(:job_preferences, working_patterns: %w[full_time], locations: [full_time_job_preference_location]) }
      let(:full_time_job_preference_location) { create(:job_preferences_location, **location_preference) }

      it "should only return the jobseeker profiles with the working patterns specified in the filters" do
        expect(search.jobseeker_profiles).to eq([full_time_jobseeker_profile])
      end

      context "searching using multiple working_patterns" do
        let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], working_patterns: %w[full_time part_time], phases: [], key_stages: [], subjects: [] } }

        let!(:part_time_jobseeker_profile) { create(:jobseeker_profile, job_preferences: part_time_job_preferences) }
        let(:part_time_job_preferences) { create(:job_preferences, working_patterns: %w[part_time], locations: [part_time_job_preference_location]) }
        let(:part_time_job_preference_location) { create(:job_preferences_location, **location_preference) }

        it "should return the jobseeker profiles with the working patterns specified in the filters" do
          expect(search.jobseeker_profiles).to match_array([full_time_jobseeker_profile, part_time_jobseeker_profile])
        end
      end
    end

    context "job_preferences phases" do
      let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], roles: [], working_patterns: [], phases: %w[secondary], key_stages: [], subjects: [] } }
      let(:control_job_preferences_attrs) { { phases: %w[sixth_form_or_college] } }
      let(:control_profile_attrs) { {} }

      let(:secondary_jobseeker_profile) { create(:jobseeker_profile) }
      let(:secondary_job_preferences) { create(:job_preferences, phases: %w[secondary], jobseeker_profile: secondary_jobseeker_profile) }
      let!(:secondary_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: secondary_job_preferences) }

      it "should only return the jobseeker profiles with the phases specified in the filters" do
        expect(search.jobseeker_profiles).to eq([secondary_jobseeker_profile])
      end

      context "searching using multiple phases" do
        let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], working_patterns: [], phases: %w[primary secondary], key_stages: [], subjects: [] } }

        let(:primary_jobseeker_profile) { create(:jobseeker_profile) }
        let(:primary_job_preferences) { create(:job_preferences, phases: %w[primary], jobseeker_profile: primary_jobseeker_profile) }
        let!(:primary_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: primary_job_preferences) }

        it "should return the jobseeker profiles with the phases specified in the filters" do
          expect(search.jobseeker_profiles).to match_array([secondary_jobseeker_profile, primary_jobseeker_profile])
        end
      end
    end

    context "job_preferences key_stages" do
      let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], roles: [], working_patterns: [], phases: [], key_stages: %w[ks1], subjects: [] } }
      let(:control_job_preferences_attrs) { { key_stages: %w[ks4] } }
      let(:control_profile_attrs) { {} }

      let(:ks1_jobseeker_profile) { create(:jobseeker_profile) }
      let(:ks1_job_preferences) { create(:job_preferences, key_stages: %w[ks1], jobseeker_profile: ks1_jobseeker_profile) }
      let!(:ks1_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: ks1_job_preferences) }

      it "should only return the jobseeker profiles with the key_stages specified in the filters" do
        expect(search.jobseeker_profiles).to eq([ks1_jobseeker_profile])
      end

      context "searching using multiple key_stages" do
        let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], working_patterns: [], phases: [], key_stages: %w[ks1 ks2], subjects: [] } }

        let(:ks2_jobseeker_profile) { create(:jobseeker_profile) }
        let(:ks2_job_preferences) { create(:job_preferences, key_stages: %w[ks2], jobseeker_profile: ks2_jobseeker_profile) }
        let!(:ks2_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: ks2_job_preferences) }

        it "should return the jobseeker profiles with the key_stages specified in the filters" do
          expect(search.jobseeker_profiles).to match_array([ks1_jobseeker_profile, ks2_jobseeker_profile])
        end
      end
    end

    context "job_preferences subjects" do
      let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], roles: [], working_patterns: [], phases: [], key_stages: [], subjects: %w[History] } }
      let(:control_job_preferences_attrs) { { subjects: %w[Biology] } }
      let(:control_profile_attrs) { {} }

      let(:history_jobseeker_profile) { create(:jobseeker_profile) }
      let(:history_job_preferences) { create(:job_preferences, subjects: %w[History], jobseeker_profile: history_jobseeker_profile) }
      let!(:history_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: history_job_preferences) }

      it "should only return the jobseeker profiles with subjects present in the filters" do
        expect(search.jobseeker_profiles).to eq([history_jobseeker_profile])
      end

      context "searching using multiple subjects" do
        let(:filters) { { current_organisation: organisation, qualified_teacher_status: [], working_patterns: [], phases: [], key_stages: [], subjects: %w[History Chemistry] } }

        let(:chemistry_jobseeker_profile) { create(:jobseeker_profile) }
        let(:chemistry_job_preferences) { create(:job_preferences, subjects: %w[Chemistry], jobseeker_profile: chemistry_jobseeker_profile) }
        let!(:chemistry_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: chemistry_job_preferences) }

        it "should return the jobseeker profiles with the key_stages specified in the filters" do
          expect(search.jobseeker_profiles).to match_array([history_jobseeker_profile, chemistry_jobseeker_profile])
        end
      end
    end

    context "when multiple filters have been applied" do
      let(:filters) { { current_organisation: organisation, qualified_teacher_status: %w[yes], roles: %w[teacher], working_patterns: %w[part_time], phases: %w[primary], key_stages: %w[KS1], subjects: [] } }
      let(:control_job_preferences_attrs) { { roles: %w[leader], working_patterns: %w[full_time], phases: %w[secondary], key_stages: %w[KS4] } }
      let(:control_profile_attrs) { { qualified_teacher_status: "no" } }

      let(:jobseeker_profile) { create(:jobseeker_profile, qualified_teacher_status: "yes") }
      let(:job_preferences) { create(:job_preferences, roles: %w[teacher], working_patterns: %w[part_time], phases: %w[primary], key_stages: %w[KS1], jobseeker_profile:) }
      let!(:job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: job_preferences) }

      it "should return a jobseeker profile with an attribute matching any of the values used in the filter" do
        expect(search.jobseeker_profiles).to eq([jobseeker_profile])
      end
    end
  end
end
