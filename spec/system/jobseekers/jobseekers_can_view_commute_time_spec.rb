require "rails_helper"

RSpec.describe "Jobseekers can view commute time", :js do
  let(:vacancy) { create(:vacancy) }
  let(:durations) { { "driving" => 26, "walking" => 95, "transit" => 47 } }

  before do
    allow(CommuteTime).to receive(:new) do |travel_mode:, **|
      instance_double(CommuteTime, duration_in_minutes: durations.fetch(travel_mode))
    end
  end

  it "loads driving, walking and public transport times within the vacancy page" do
    page.current_window.resize_to(768, 1_024)
    visit job_path(vacancy, search_location: "SW1A 1AA")
    find("turbo-frame.commute-time").scroll_to(:center)

    expect(page).to have_content("Driving")
    expect(page).to have_content("26 minutes")
    expect(page).to have_content("Walking")
    expect(page).to have_content("1 hour 35 minutes")
    expect(page).to have_content("Public transport")
    expect(page).to have_content("47 minutes")
    expect(page).to have_content("From SW1A 1AA")
    expect(page).to have_current_path(job_path(vacancy, search_location: "SW1A 1AA"))
  end

  it "does not show or load commute times on desktop" do
    page.current_window.resize_to(1_280, 1_024)
    expect(CommuteTime).not_to receive(:new)

    visit job_path(vacancy, search_location: "SW1A 1AA")

    expect(page).to have_css(".commute-time", visible: :hidden)
  end
end
