require "rails_helper"

RSpec.describe JobseekerProfileQuery do
  subject(:query) { described_class.new(filters, london_school) }

  let(:filters) do
    {
      qualified_teacher_status: [],
      roles: [],
      working_patterns: [],
      phases: [],
      key_stages: [],
    }
  end
  let(:london_school) { double("School", geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(-0.16443, 51.51680)) }

  context "when there are no job seekers in the school area" do
    let(:job_preferences_locations) { JobPreferences::Location.none }

    before do
      allow(JobPreferences::Location).to receive(:containing)
        .with(london_school.geopoint).and_return(job_preferences_locations)
    end

    it "returns profiles within the organisation area" do
      expect(query.call).to be_empty
    end
  end

  context "when there are job seekers in the school area and no filters" do
    let(:london_preference) { create(:job_preferences_location, name: "London", radius: 100) }
    let(:job_preferences) { create(:job_preferences, locations: [london_preference]) }
    let(:jobseeker_profile) { create(:jobseeker_profile, job_preferences: job_preferences) }
    let!(:jobseeker) { create(:jobseeker, jobseeker_profile: jobseeker_profile) }

    let(:manchester_preference) { create(:job_preferences_location, name: "Manchester") }

    before do
      create(:location_polygon, name: "london")
      create(:location_polygon, name: "manchester")
    end

    it "returns profiles within the organisation area" do
      expect(query.call).to include(jobseeker_profile)
    end

    it "does not return profiles outside the organisation area" do
      expect(query.call).not_to include(manchester_preference.job_preferences.jobseeker_profile)
    end
  end

  context "with filters" do
    let(:london_preferences) { create(:job_preferences_location, name: "London", radius: 100) }
    let(:job_preferences) { create(:job_preferences, locations: [london_preferences], roles: ["Teacher"]) }
    let(:jobseeker_profile) { create(:jobseeker_profile, job_preferences: job_preferences) }
    let(:jobseeker!) { create(:jobseeker, jobseeker_profile: jobseeker_profile) }

    let(:job_preferences2) { create(:job_preferences, locations: [london_preferences], roles: ["Leader"]) }
    let(:jobseeker_profile2) { create(:jobseeker_profile, job_preferences: job_preferences2) }
    let(:jobseeker2!) { create(:jobseeker, jobseeker_profile2: jobseeker_profile) }

    let(:filters) do
      {
        qualified_teacher_status: [],
        roles: ["Leader"],
        working_patterns: [],
        phases: [],
        key_stages: [],
      }
    end

    it "it applies filters correctly" do
      expect(query.call).to include(jobseeker_profile2)
    end

    it "returns profiles filtered" do
      expect(query.call).not_to include(jobseeker_profile)
    end

    context "QTS filter" do
      let(:filters) do
        {
          qualified_teacher_status: ["awarded"],
          roles: [],
          working_patterns: [],
          phases: [],
          key_stages: [],
        }
      end

      let(:jobseeker_profile) { create(:jobseeker_profile, job_preferences: job_preferences, qualified_teacher_status: "yes") }
      let(:jobseeker_profile2) { create(:jobseeker_profile, job_preferences: job_preferences2, qualified_teacher_status: "no") }

      it "it applies filters correctly" do
        expect(query.call).to include(jobseeker_profile)
      end

      it "returns profiles filtered" do
        expect(query.call).not_to include(jobseeker_profile2)
      end
    end
  end
end
