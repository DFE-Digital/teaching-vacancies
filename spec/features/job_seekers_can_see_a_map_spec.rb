require 'rails_helper'

RSpec.feature 'Viewing a vacancy' do
  scenario 'should display a map when a school has geocoding', browserstack: true do
    school = create(:school,
                    easting: '537224',
                    northing: '177395',
                    geolocation: '51.4788757883318, 0.0253328559417984')
    vacancy = create(:vacancy, school: school)
    visit job_path(vacancy)
    expect(page).to have_css('div#map_zoom')
  end

  scenario 'should not display a map when a school has no geocoding' do
    school = create(:school, easting: nil, northing: nil)
    vacancy = create(:vacancy, school: school)
    visit job_path(vacancy)
    expect(page).not_to have_css('div#map_zoom')
  end
end
