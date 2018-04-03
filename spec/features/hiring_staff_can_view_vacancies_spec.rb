require 'rails_helper'

RSpec.feature 'School viewing vacancies' do
  include_context 'when authenticated as a member of hiring staff',
                  stub_basic_auth_env: true

  scenario 'A school should see advisory text when there are no vacancies', elasticsearch: true do
    school = FactoryGirl.create(:school)
    visit school_path(school)

    expect(page).to have_content(I18n.t('schools.vacancies.index', school: school.name))
    expect(page).not_to have_css('table.vacancies')
    expect(page).to have_content('You have no current vacancies.')
  end

  scenario 'A school can see a list of vacancies', elasticsearch: true do
    school = FactoryGirl.create(:school)
    vacancy1 = FactoryGirl.create(:vacancy, school: school)
    vacancy2 = FactoryGirl.create(:vacancy, school: school)
    visit school_path(school)

    expect(page).to have_content(I18n.t('schools.vacancies.index', school: school.name))
    expect(page).to have_content(vacancy1.job_title)
    expect(page).to have_content(vacancy2.job_title)
  end

  scenario 'A draft vacancy redirects to the vacancy review page' do
    school = FactoryGirl.create(:school)
    vacancy = FactoryGirl.create(:vacancy, :draft, school: school)
    visit school_vacancy_path(school_id: school.id, id: vacancy.id)

    expect(page.current_path).to eq(school_vacancy_review_path(school, vacancy.id))
    expect(page).to have_content(I18n.t('vacancies.view.only_published'))
  end

  scenario 'A published vacancy show page should not show a flash message with the status', elasticsearch: true do
    school = FactoryGirl.create(:school)
    vacancy = FactoryGirl.create(:vacancy, :published, school: school)
    visit school_vacancy_path(school, vacancy.id)
    expect(page).to have_content(school.name)
    expect(page).to have_content(vacancy.job_title)
  end
end
