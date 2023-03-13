require "rails_helper"

RSpec.describe Search::JobseekerProfileSearch do
  subject(:search) { described_class.new(filters, organisation) }

  context "when no filters have been applied" do
    let(:filters) { { qualified_teacher_status: [], roles: [], working_patterns: [], phases: [], key_stages: [] } }

    context "when the organisation is a school" do
      let(:organisation) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(0.2861, 51.7094)) }

      context "when no job preference area contains the school" do
        it "returns an empty array" do
          expect(search.jobseeker_profiles).to be_empty
        end
      end

      context "when a job preference area contains the school" do
        let!(:jobseeker) { create(:jobseeker, jobseeker_profile: jobseeker_profile) }
        let(:jobseeker_profile) { create(:jobseeker_profile, job_preferences: job_preferences) }
        let(:job_preferences) { create(:job_preferences, locations: [london_location_preference]) }
        let(:london_location_preference) { create(:job_preferences_location, name: "London", radius: 100) }
        let(:manchester_location_preference) { create(:job_preferences_location, name: "Manchester", radius: 10) }

        before do
          create(:location_polygon, name: "london")
          create(:location_polygon, name: "manchester")
        end

        it "returns the jobseeker profiles with preference areas that contain the school" do
          expect(search.jobseeker_profiles).to include(jobseeker_profile)
        end

        it "does not return jobseeker profiles with preference areas that don't contain the school" do
          expect(search.jobseeker_profiles).not_to include(manchester_location_preference.job_preferences.jobseeker_profile)
        end
      end
    end

    context "when the organisation is a trust" do
      let!(:organisation) { create(:trust, schools: [school1, school2]) }

      let(:jobseeker_profile) { create(:jobseeker_profile, job_preferences: job_preferences) }
      let(:job_preferences) { create(:job_preferences, locations: [location_preference_including_school1]) }
      let(:location_near_school1) { [51.5538288, -0.1110617] }
      let(:location_preference_including_school1) { create(:job_preferences_location, name: "N7 7DD", radius: 2) }
      let(:school1) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(-0.1084749, 51.5542907)) }

      let(:jobseeker_profile2) { create(:jobseeker_profile, job_preferences: job_preferences2) }
      let(:job_preferences2) { create(:job_preferences, locations: [location_preference_including_school2]) }
      let(:location_near_school2) { [51.5080513, -0.1080925] }
      let(:location_preference_including_school2) { create(:job_preferences_location, name: "SE1 9NA", radius: 2) }
      let(:school2) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(-0.1082545, 51.5067853)) }

      before do
        allow(JobPreferences::Location).to receive(:containing).and_call_original
        allow(Geocoding).to receive(:test_coordinates).and_return(location_near_school1)
        allow(Geocoding).to receive(:test_coordinates).and_return(location_near_school2)
        create(:jobseeker, jobseeker_profile: jobseeker_profile)
        create(:jobseeker, jobseeker_profile: jobseeker_profile2)
      end

      it "searches for jobseeker profiles using the location of every individual school within the trust" do
        search.jobseeker_profiles

        expect(JobPreferences::Location).to have_received(:containing).with(school1.geopoint)
        expect(JobPreferences::Location).to have_received(:containing).with(school2.geopoint)
      end

      it "returns every jobseeker profile with a preference area that contains any of their schools" do
        expect(search.jobseeker_profiles).to eq([jobseeker_profile, jobseeker_profile2])
      end
    end
  end

  describe "filtering a search" do
    let!(:organisation) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(-0.1084749, 51.5542907)) }
    let(:location_near_organisation) { [51.5538288, -0.1110617] }
    let(:location_preference) { { name: "N7 7DD", radius: 2 } }
    let!(:control_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: control_job_preferences) }
    let(:control_job_preferences) { create(:job_preferences, **control_job_preferences_attrs, jobseeker_profile: control_jobseeker_profile) }
    let(:control_jobseeker_profile) { create(:jobseeker_profile, **control_profile_attrs) }

    before { allow(Geocoding).to receive(:test_coordinates).and_return(location_near_organisation) }

    context "jobseeker_profile qualified_teacher_status" do
      let(:filters) { { qualified_teacher_status: "yes", roles: [], working_patterns: [], phases: [], key_stages: [] } }
      let(:control_profile_attrs) { { qualified_teacher_status: "no" } }
      let(:control_job_preferences_attrs) { {} }

      let!(:qts_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: qts_job_preferences) }
      let(:qts_job_preferences) { create(:job_preferences, jobseeker_profile: qts_jobseeker_profile) }
      let(:qts_jobseeker_profile) { create(:jobseeker_profile, qualified_teacher_status: "yes") }

      it "should only return the jobseeker profiles with the qualified_teacher_status specified in the filters" do
        expect(search.jobseeker_profiles).to eq([qts_jobseeker_profile])
      end
    end

    context "job_preferences roles" do
      let(:filters) { { qualified_teacher_status: [], roles: %w[teacher], working_patterns: [], phases: [], key_stages: [] } }
      let(:control_job_preferences_attrs) { { roles: %w[leader] } }
      let(:control_profile_attrs) { {} }

      let!(:teacher_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: teacher_job_preferences) }
      let(:teacher_job_preferences) { create(:job_preferences, roles: %w[teacher], jobseeker_profile: teacher_jobseeker_profile) }
      let(:teacher_jobseeker_profile) { create(:jobseeker_profile) }

      it "should only return the jobseeker profiles with the qualified_teacher_status specified in the filters" do
        expect(search.jobseeker_profiles).to eq([teacher_jobseeker_profile])
      end
    end

    context "job_preferences working_patterns" do
      let(:filters) { { qualified_teacher_status: [], roles: [], working_patterns: %w[full_time], phases: [], key_stages: [] } }
      let(:control_job_preferences_attrs) { { working_patterns: %w[part_time] } }
      let(:control_profile_attrs) { {} }

      let!(:full_time_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: full_time_job_preferences) }
      let(:full_time_job_preferences) { create(:job_preferences, working_patterns: %w[full_time], jobseeker_profile: full_time_jobseeker_profile) }
      let(:full_time_jobseeker_profile) { create(:jobseeker_profile) }

      it "should only return the jobseeker profiles with the qualified_teacher_status specified in the filters" do
        expect(search.jobseeker_profiles).to eq([full_time_jobseeker_profile])
      end
    end

    context "job_preferences phases" do
      let(:filters) { { qualified_teacher_status: [], roles: [], working_patterns: [], phases: %w[secondary], key_stages: [] } }
      let(:control_job_preferences_attrs) { { phases: %w[primary] } }
      let(:control_profile_attrs) { {} }

      let!(:secondary_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: secondary_job_preferences) }
      let(:secondary_job_preferences) { create(:job_preferences, phases: %w[secondary], jobseeker_profile: secondary_jobseeker_profile) }
      let(:secondary_jobseeker_profile) { create(:jobseeker_profile) }

      it "should only return the jobseeker profiles with the qualified_teacher_status specified in the filters" do
        expect(search.jobseeker_profiles).to eq([secondary_jobseeker_profile])
      end
    end

    context "job_preferences key_stages" do
      let(:filters) { { qualified_teacher_status: [], roles: [], working_patterns: [], phases: [], key_stages: %w[KS1] } }
      let(:control_job_preferences_attrs) { { key_stages: %w[KS2] } }
      let(:control_profile_attrs) { {} }

      let!(:ks1_job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: ks1_job_preferences) }
      let(:ks1_job_preferences) { create(:job_preferences, key_stages: %w[KS1], jobseeker_profile: ks1_jobseeker_profile) }
      let(:ks1_jobseeker_profile) { create(:jobseeker_profile) }

      it "should only return the jobseeker profiles with the qualified_teacher_status specified in the filters" do
        expect(search.jobseeker_profiles).to eq([ks1_jobseeker_profile])
      end
    end

    context "when multiple filters in the same group have been applied" do
      let(:filters) { { qualified_teacher_status: [], roles: [], working_patterns: [], phases: [], key_stages: %w[KS1 KS2] } }
      let(:control_job_preferences_attrs) { { key_stages: %w[KS3] } }
      let(:control_profile_attrs) { {} }

      let!(:job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: job_preferences) }
      let(:job_preferences) { create(:job_preferences, key_stages: %w[KS1], jobseeker_profile: jobseeker_profile) }
      let(:jobseeker_profile) { create(:jobseeker_profile) }

      it "should return a jobseeker profile with an attribute matching any of the values used in the filter" do
        expect(search.jobseeker_profiles).to eq([jobseeker_profile])
      end
    end

    context "when multiple filters have been applied" do
      let(:filters) { { qualified_teacher_status: %w[yes], roles: %w[teacher], working_patterns: %w[part_time], phases: %w[primary], key_stages: %w[KS1] } }
      let(:control_job_preferences_attrs) { { roles: %w[leader], working_patterns: %w[full_time], phases: %w[secondary], key_stages: %w[KS4] } }
      let(:control_profile_attrs) { { qualified_teacher_status: "no" } }

      let!(:job_preference_location) { create(:job_preferences_location, **location_preference, job_preferences: job_preferences) }
      let(:job_preferences) { create(:job_preferences, roles: %w[teacher], working_patterns: %w[part_time], phases: %w[primary], key_stages: %w[KS1], jobseeker_profile: jobseeker_profile) }
      let(:jobseeker_profile) { create(:jobseeker_profile, qualified_teacher_status: "yes") }

      it "should return a jobseeker profile with an attribute matching any of the values used in the filter" do
        expect(search.jobseeker_profiles).to eq([jobseeker_profile])
      end
    end
  end
end
