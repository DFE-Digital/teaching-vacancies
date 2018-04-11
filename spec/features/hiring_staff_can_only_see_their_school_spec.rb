require 'rails_helper'

RSpec.feature 'Hiring staff can only see their school' do
  context 'when the session is connected to a school' do
    scenario 'school page can be viewed' do
      school = create(:school)
      stub_hiring_staff_auth(urn: school.urn)

      visit school_path(school)

      expect(page).to have_content(school.name)
    end
  end

  context 'when the log in is NOT connected to a school' do
    scenario 'returns a 404' do
      school = create(:school)
      stub_hiring_staff_auth(urn: 'foo')

      visit school_path(school)

      expect(page).to have_content('Page not found')
    end
  end
end
