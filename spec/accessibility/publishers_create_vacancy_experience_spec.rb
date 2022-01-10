require "rails_helper"

RSpec.describe "Publisher experience", type: :system, accessibility: true do
  let(:organisation) { create(:school) }
  let(:publisher) { create(:publisher) }

  before { login_publisher(publisher:, organisation:) }

  context "Publisher creates a vacancy" do
    describe "Job details page" do
      before do
        visit organisation_path
        click_on I18n.t("buttons.create_job")
      end

      it "it meets accessibility standards" do
        expect(page).to meet_accessibility_standards.excluding(".govuk-radios__item")
      end
    end
  end
end
