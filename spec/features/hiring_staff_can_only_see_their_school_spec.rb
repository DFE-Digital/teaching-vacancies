require 'rails_helper'

RSpec.feature 'Hiring staff can only see their school' do
  let(:school) { create(:school) }

  before(:each) { stub_authenticate_hiring_staff(return_value: true) }

  context 'when the log in is connected to a school' do
    before(:each) do
      stub_access_basic_auth_env(env_field_for_username: :benwick_http_user,
                                 env_field_for_password: :benwick_http_pass,
                                 env_value_for_username: 'benwick',
                                 env_value_for_password: 'foobarbazzzz')
    end

    include_context 'when authenticated as a member of hiring staff', username: 'benwick', password: 'foobarbazzzz'
    scenario 'school appears in search results' do
      school = create(:school, name: 'Benwick Primary School')

      visit schools_path

      fill_in 'School name', with: school.name

      click_on 'Find'

      expect(page).to have_content(school.name)
    end

    scenario 'no other schools appear' do
      matching_search_term = 'School'
      school = create(:school, name: "Benwick Primary #{matching_search_term}")
      another_school = create(:school, name: "Another #{matching_search_term}")

      visit schools_path

      fill_in 'School name', with: matching_search_term

      click_on 'Find'

      expect(page).not_to have_content(another_school.name)
    end
  end

  context 'when the log in is NOT connected to a school' do
    scenario 'no school is listed' do
      school = create(:school, name: 'Benwick Primary School')

      visit schools_path

      fill_in 'School name', with: school.name

      click_on 'Find'

      expect(page).not_to have_content(school.name)
    end
  end
end
