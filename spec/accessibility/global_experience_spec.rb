require "rails_helper"

RSpec.describe "Global experience", type: :system, accessibility: true do
  let(:school) { create(:school) }
  let!(:job1) { create(:vacancy, :past_publish, job_title: "Teacher of Potions", organisations: [school]) }

  context "A global user" do
    describe "visits the T&C page" do
      before { visit terms_and_conditions_path }
      it "it meets accessibility standards" do
        expect(page).to meet_accessibility_standards
      end
    end

    describe "visits the give feedback page" do
      before { visit new_feedback_path }
      it "it meets accessibility standards" do
        expect(page).to meet_accessibility_standards.excluding(".govuk-radios__item")
      end
    end

    describe "visits the cookie preference page" do
      before { visit cookies_preferences_path }
      it "it meets accessibility standards" do
        expect(page).to meet_accessibility_standards
      end
    end
  end
end
