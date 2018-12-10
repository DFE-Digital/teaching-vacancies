require 'rails_helper'

RSpec.feature 'Hiring staff can see their vacancies' do
  scenario 'school with geolocation' do
    school = create(:school, northing: '1', easting: '2')

    stub_hiring_staff_auth(urn: school.urn)
    vacancy = create(:vacancy, school: school, status: 'published')

    visit school_path

    click_on(vacancy.job_title)

    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(vacancy.job_description)
  end
end
