require "rails_helper"

RSpec.describe "Viewing a vacancy" do
  let(:vacancy) { create(:vacancy, organisations: [school]) }

  before { visit job_path(vacancy) }

  context "when a school has geocoding" do
    let(:school) { create(:school, geopoint: "POINT(51.4788757883318 0.0253328559417984)") }

    it "displays a map " do
      expect(page).to have_css("div#map")
    end
  end

  context "when a school has no geocoding" do
    let(:school) { create(:school, geopoint: nil) }

    it "does not display a map " do
      expect(page).not_to have_css("div#map")
    end
  end
end
