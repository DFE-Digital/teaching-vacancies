require 'rails_helper'
RSpec.feature 'Job seekers cannot manage vacancies' do
  before(:each) do
    stub_access_basic_auth_env(env_field_for_username: :http_user,
                               env_field_for_password: :http_pass,
                               env_value_for_username: nil,
                               env_value_for_password: nil)
  end

  scenario 'An unauthenticated user tries to create a vacancy' do
    school = create(:school)
    path = new_school_vacancy_path(school.id)

    visit path

    expect(page).to have_content('HTTP Basic: Access denied.')
  end

  scenario 'An unauthenticated user tries to update a vacancy' do
    school = create(:school)
    vacancy = create(:vacancy, school: school)
    path = school_vacancy_path(school.id, vacancy)

    visit path

    expect(page).to have_content('HTTP Basic: Access denied.')
  end
end
