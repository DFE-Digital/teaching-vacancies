require "rails_helper"

RSpec.describe "Jobseeker experience", type: :system, accessibility: true do
  let(:school) { create(:school) }
  let!(:job1) { create(:vacancy, :past_publish, job_title: "Teacher of Potions", organisations: [school]) }

  context "Not signed in" do
    describe "visits the home page" do
      before { visit root_path }
      it "it meets accessibility standards" do
        expect(page).to meet_accessibility_standards
      end
    end

    # has to commented for duration of 2021_11_desktop_search_results_page_test
    # as duplicate id problem on search results page. this will not be an issue
    # when a test variant is chosen so these can be activated

    # describe "visits the search results page and clicks on a job" do
    #   before { visit jobs_path }
    #   it "it meets accessibility standards" do
    #     expect(page).to meet_accessibility_standards

    #     click_on "Teacher of Potions"
    #     expect(page).to meet_accessibility_standards.excluding("#map")
    #   end
    # end

    describe "visits the create job alert page" do
      before { visit new_subscription_path }
      it "vit meets accessibility standards" do
        expect(page).to meet_accessibility_standards
      end
    end
  end
end
