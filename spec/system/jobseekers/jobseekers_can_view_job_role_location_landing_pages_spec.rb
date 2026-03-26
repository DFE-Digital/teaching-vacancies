require "rails_helper"

RSpec.describe "Jobseekers can view job role + location landing pages" do
  context "when visiting a teaching job role + location landing page" do
    it "correctly displays filters and titles" do
      visit "/sendco-jobs-in-london"

      expect(page).to have_checked_field("SENDCo")
      location_field = page.find("input[name='location']", visible: :all)
      expect(location_field.value).to eq("London")
      expect(page).to have_title("SENDCo (special educational needs and disabilities coordinator) Jobs in London")
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

end
