require 'rails_helper'

RSpec.feature 'School viewing vacancies' do
  include_context 'when authenticated as a member of hiring staff',
                  stub_basic_auth_env: true

  scenario 'Navigate from viewing a vacancy to all vacancies for that school' do
    school = FactoryGirl.create(:school)
    vacancy = FactoryGirl.create(:vacancy, school: school)

    visit school_vacancy_path(school_id: school.id, id: vacancy.id)

    expect(page).to have_css('.breadcrumbs')
    within('.breadcrumbs') do
      expect(page).to have_content(school.name)
      expect(page).to have_content(vacancy.job_title)
    end

    click_on school.name
    expect(page).to have_content("Vacancies at #{school.name}")
  end

  scenario 'Navigate from editing an active vacancy to all vacancies for that school' do
    school = FactoryGirl.create(:school)
    vacancy = FactoryGirl.create(:vacancy, school: school)

    visit edit_school_vacancy_path(school_id: school.id, id: vacancy.id)

    expect(page).to have_css('.breadcrumbs')
    within('.breadcrumbs') do
      expect(page).to have_content(school.name)
      expect(page).to have_content(vacancy.job_title)
    end

    click_on school.name
    expect(page).to have_content("Vacancies at #{school.name}")
  end

  scenario 'Navigate from reviewing a draft vacancy to all vacancies for that school' do
    school = FactoryGirl.create(:school)
    vacancy = FactoryGirl.create(:vacancy, school: school)

    visit school_vacancy_review_path(school_id: school.id, vacancy_id: vacancy.id)

    expect(page).to have_css('.breadcrumbs')
    within('.breadcrumbs') do
      expect(page).to have_content(school.name)
      expect(page).to have_content(vacancy.job_title)
    end

    click_on school.name
    expect(page).to have_content("Vacancies at #{school.name}")
  end
end
