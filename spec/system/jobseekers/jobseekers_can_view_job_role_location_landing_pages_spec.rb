require "rails_helper"

RSpec.describe "Jobseekers can view job role + location landing pages" do
  before do
    create(:location_polygon, name: "birmingham")
    create(:location_polygon, name: "manchester")
    create(:location_polygon, name: "stoke-on-trent")
  end

  context "when visiting a teaching job role + location landing page" do
    it "correctly displays filters and titles for teacher" do
      visit "/teacher-jobs-in-birmingham"

      expect(page).to have_checked_field("Teacher")
      location_field = page.find("input[name='location']", visible: :all)
      expect(location_field.value).to eq("Birmingham")
      expect(page).to have_title("Teacher Jobs in Birmingham")

      visit "/headteacher-jobs-in-birmingham"

      expect(page).to have_checked_field("Headteacher")
      location_field = page.find("input[name='location']", visible: :all)
      expect(location_field.value).to eq("Birmingham")
      expect(page).to have_title("Headteacher Jobs in Birmingham")
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

  context "when location has a multi word the name" do
    scenario "handles locations correctly" do
      visit "/teacher-jobs-in-stoke-on-trent"

      location_field = page.find("input[name='location']", visible: :all)
      expect(location_field.value).to eq("Stoke On Trent")
    end
  end

  context "when job role or location doesn't exist" do
    scenario "returns 404 when job role doesn't exist" do
      visit "/footballer-jobs-in-birmingham"

      expect(page).to have_http_status(:not_found)
    end

    scenario "returns 404 when location doesn't exist" do
      visit "/teacher-jobs-in-xxxxx"

      expect(page).to have_http_status(:not_found)
    end
  end
end
