require "rails_helper"

RSpec.describe "Contacting Jobseekers" do
  include ActiveJob::TestHelper

  let!(:job_preferences) do
    create(:job_preferences,
           roles: %w[headteacher],
           phases: %w[primary],
           key_stages: %w[ks1 ks2],
           subjects: %w[english maths],
           working_patterns: %w[full_time])
  end
  let!(:location_preference) { create(:job_preferences_location, name: "London", radius: 200, job_preferences: job_preferences) }
  let!(:jobseeker_profile) { create(:jobseeker_profile, :completed, job_preferences:) }

  let!(:organisation) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(0.2861, 51.7094)) }
  let!(:publisher) { create(:publisher, organisations: [organisation]) }
  let!(:vacancy) do
    create(:vacancy,
           :published,
           organisations: publisher.organisations,
           publisher: publisher,
           job_roles: %w[headteacher],
           phases: job_preferences.phases,
           key_stages: job_preferences.key_stages,
           subjects: job_preferences.subjects,
           working_patterns: job_preferences.working_patterns)
  end

  let(:location_in_london) { [51.5072, -0.1275] }
  let(:candidate_name) do
    "#{jobseeker_profile.personal_details.first_name} #{jobseeker_profile.personal_details.last_name}"
  end

  before do
    allow(Geocoding).to receive(:test_coordinates).and_return(location_in_london)
  end

  it "A publisher can contact the jobseeker from their profile" do
    login_publisher(publisher:)
    visit root_path
    click_on "Candidate profiles"

    click_on candidate_name
    expect(page).to have_link(jobseeker_profile.email, href: "mailto:#{jobseeker_profile.email}")
  end
end
