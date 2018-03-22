require 'rails_helper'
RSpec.feature 'School viewing vacancies' do
  scenario 'A school can see a list of vacancies', elasticsearch: true do
    school = FactoryGirl.create(:school)
    vacancy1 = FactoryGirl.create(:vacancy, school: school)
    vacancy2 = FactoryGirl.create(:vacancy, school: school)
    visit school_vacancies_path(school.id)

    expect(page).to have_content(I18n.t('schools.vacancies.index', school: school.name))
    expect(page).to have_content(vacancy1.job_title)
    expect(page).to have_content(vacancy2.job_title)
  end
end
