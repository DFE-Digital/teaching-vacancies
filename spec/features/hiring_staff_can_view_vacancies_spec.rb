require 'rails_helper'

RSpec.feature 'School viewing vacancies' do
  let(:school) { create(:school) }
  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'A school should see advisory text when there are no vacancies' do
    visit school_path(school)

    expect(page).to have_content(I18n.t('schools.vacancies.index', school: school.name))
    expect(page).not_to have_css('table.vacancies')
    expect(page).to have_content('You have no current vacancies.')
  end

  scenario 'A school can see a list of vacancies' do
    vacancy1 = create(:vacancy, school: school)
    vacancy2 = create(:vacancy, school: school)

    visit school_path(school)

    expect(page).to have_content(I18n.t('schools.vacancies.index', school: school.name))
    expect(page).to have_content(vacancy1.job_title)
    expect(page).to have_content(vacancy2.job_title)
  end

  scenario 'A draft vacancy show page should show a flash message with the status', elasticsearch: true do
    vacancy = create(:vacancy, school: school, status: 'draft')

    visit school_vacancy_path(school_id: school.id, id: vacancy.id)

    expect(page).to have_content(school.name)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(I18n.t('messages.vacancies.view.only_published'))
  end

  scenario 'A published vacancy show page should not show a flash message with the status' do
    vacancy = create(:vacancy, school: school, status: 'published')
    visit school_vacancy_path(school, vacancy.id)

    expect(page).to have_content(school.name)
    expect(page).to have_content(vacancy.job_title)
  end
end
