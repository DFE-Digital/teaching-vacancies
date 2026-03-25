require "rails_helper"

RSpec.describe "Jobseekers can view job role + location landing pages" do
  context "when visiting a teaching job role + location landing page" do
    it "correctly displays filters and titles" do
      visit "/sendco-jobs-in-london"

      expect(page).to have_checked_field("SENDCo")
      location_field = page.find("input[name='location']", visible: :all)
      expect(location_field.value).to eq("London")
      expect(page).to have_title("SENDCo Jobs in London")
    end
  end

  context "when visiting a support job role + location landing page" do
    it "correctly displays filters and titles" do
      visit "/teaching-assistant-jobs-in-birmingham"

      expect(page).to have_checked_field("Teaching assistant")
      location_field = page.find("input[name='location']", visible: :all)
      expect(location_field.value).to eq("Birmingham")
      expect(page).to have_title("Teaching assistant Jobs in Birmingham")
    end
  end

  context "when job role or location is not in the targeted list" do
    scenario "returns 404 for a valid job role not in the targeted list" do
      visit "/teacher-jobs-in-london"

      expect(page).to have_http_status(:not_found)
    end

    scenario "returns 404 for a valid location not in the targeted list" do
      visit "/teaching-assistant-jobs-in-leeds"

      expect(page).to have_http_status(:not_found)
    end

    scenario "returns 404 for a completely unknown combo" do
      visit "/footballer-jobs-in-birmingham"

      expect(page).to have_http_status(:not_found)
    end
  end
end
