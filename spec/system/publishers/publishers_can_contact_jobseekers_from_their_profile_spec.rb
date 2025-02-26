require "rails_helper"

# Not a system test - could be a simple view spec as it has a lot of test
# for 1 simple assert
RSpec.describe "Contacting Jobseekers" do
  let!(:job_preferences) do
    create(:job_preferences,
           roles: %w[headteacher],
           phases: %w[primary],
           key_stages: %w[ks1 ks2],
           subjects: %w[english maths],
           locations: build_list(:job_preferences_location, 1, name: "London", radius: 200),
           working_patterns: %w[full_time])
  end
  let!(:jobseeker_profile) { create(:jobseeker_profile, :completed, job_preferences:) }

  let!(:organisation) { create(:school, geopoint: RGeo::Geographic.spherical_factory(srid: 4326).point(0.2861, 51.7094)) }
  let!(:publisher) { create(:publisher, organisations: [organisation]) }

  let(:location_in_london) { [51.5072, -0.1275] }
  let(:candidate_name) do
    "#{jobseeker_profile.personal_details.first_name} #{jobseeker_profile.personal_details.last_name}"
  end

  before do
    allow(Geocoding).to receive(:test_coordinates).and_return(location_in_london)
    login_publisher(publisher:)
  end

  after { logout }

  scenario "A publisher can contact the jobseeker from their profile" do
    visit root_path
    click_link "Candidate profiles"

    click_link candidate_name
    expect(page).to have_link(jobseeker_profile.email, href: "mailto:#{jobseeker_profile.email}")
  end
end
