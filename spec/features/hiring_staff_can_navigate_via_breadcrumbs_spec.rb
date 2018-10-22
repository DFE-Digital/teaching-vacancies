require 'rails_helper'

RSpec.feature 'School viewing vacancies' do
  let(:school) { create(:school) }
  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'Navigate from viewing a vacancy to all vacancies for that school' do
    vacancy = create(:vacancy, school: school)

    visit school_path(school)
    expect(page).to have_content(I18n.t('schools.jobs.index', school: school.name))

    click_on(vacancy.job_title)
    within('.govuk-breadcrumbs') do
      expect(page).to have_content(school.name)
      expect(page).to have_content(vacancy.job_title)
    end

    within('.govuk-breadcrumbs') do
      click_on(school.name)
    end
    expect(page).to have_content(I18n.t('schools.jobs.index', school: school.name))
  end

  scenario 'Navigate from editing an active vacancy to all vacancies for that school' do
    vacancy = create(:vacancy, school: school)

    visit school_path(school)

    within('.vacancy') do
      click_on('Edit')
    end

    expect(page).to have_css('.govuk-breadcrumbs')
    within('.govuk-breadcrumbs') do
      expect(page).to have_content(school.name)
      expect(page).to have_content(vacancy.job_title)
    end

    click_on school.name
    expect(page).to have_content(I18n.t('schools.jobs.index', school: school.name))
  end

  scenario 'Navigate from reviewing a draft vacancy to all vacancies for that school' do
    vacancy = create(:vacancy, school: school)

    visit school_job_review_path(vacancy.id)

    expect(page).to have_css('.govuk-breadcrumbs')
    within('.govuk-breadcrumbs') do
      expect(page).to have_content(school.name)
      expect(page).to have_content(vacancy.job_title)
    end

    click_on school.name
    expect(page).to have_content(I18n.t('schools.jobs.index', school: school.name))
  end
end
