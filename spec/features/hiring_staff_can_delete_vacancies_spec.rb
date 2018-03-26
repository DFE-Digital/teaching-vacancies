require 'rails_helper'
RSpec.feature 'School deleting vacancies' do
  include_context 'when authenticated as a member of hiring staff',
                  stub_basic_auth_env: true

  scenario 'Hiring staff should see a delete button for a vacancy' do
    school = FactoryGirl.create(:school)
    vacancy = FactoryGirl.create(:vacancy, school: school)

    visit school_vacancies_path(school.id)

    within("tr#vacancy_#{vacancy.id}") do
      expect(page).to have_content(I18n.t('buttons.delete'))
    end
  end

  scenario 'A school can delete a vacancy from a list' do
    school = FactoryGirl.create(:school)
    vacancy1 = FactoryGirl.create(:vacancy, school: school)
    vacancy2 = FactoryGirl.create(:vacancy, school: school)

    visit school_vacancies_path(school.id)

    within("tr#vacancy_#{vacancy1.id}") do
      click_on 'Delete'
    end

    expect(school.vacancies.count).to equal(1)
    expect(page).not_to have_content(vacancy1.job_title)
    expect(page).to have_content(vacancy2.job_title)
    expect(page).to have_content('Your vacancy was deleted.')
  end
end
