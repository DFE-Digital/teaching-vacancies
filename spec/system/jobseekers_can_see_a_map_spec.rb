require "rails_helper"

RSpec.describe "Viewing a vacancy" do
  it "displays a map when a school has geocoding" do
    school = create(:school,
                    easting: "537224",
                    northing: "177395",
                    geolocation: "51.4788757883318, 0.0253328559417984")
    vacancy = create(:vacancy)
    vacancy.organisation_vacancies.create(organisation: school)
    visit job_path(vacancy)
    expect(page).to have_css("div#map")
  end

  it "does not display a map when a school has no geocoding" do
    school = create(:school, easting: nil, northing: nil)
    vacancy = create(:vacancy)
    vacancy.organisation_vacancies.create(organisation: school)
    visit job_path(vacancy)
    expect(page).not_to have_css("div#map")
  end
end
