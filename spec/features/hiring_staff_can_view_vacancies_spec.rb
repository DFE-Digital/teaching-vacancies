require 'rails_helper'

RSpec.feature 'School viewing vacancies' do
  let(:school) { create(:school) }
  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'A school should see advisory text when there are no vacancies' do
    visit school_path

    expect(page).to have_content(I18n.t('schools.jobs.index', school: school.name))
    expect(page).not_to have_css('table.vacancies')
    expect(page).to have_content('You have no current jobs.')
  end

  scenario 'A school can see a list of vacancies' do
    vacancy1 = create(:vacancy, school: school)
    vacancy2 = create(:vacancy, school: school)

    visit school_path

    expect(page).to have_content(I18n.t('schools.jobs.index', school: school.name))
    expect(page).to have_content(vacancy1.job_title)
    expect(page).to have_content(vacancy2.job_title)
  end

  scenario 'A draft vacancy show page should show a flash message with the status' do
    vacancy = create(:vacancy, school: school, status: 'draft')

    visit school_job_path(vacancy.id)

    expect(page).to have_content(school.name)
    expect(page).to have_content(vacancy.job_title)
    expect(page).to have_content(I18n.t('messages.jobs.view.only_published'))
  end

  scenario 'A published vacancy show page should not show a flash message with the status' do
    vacancy = create(:vacancy, school: school, status: 'published')
    visit school_job_path(vacancy.id)

    expect(page).to have_content(school.name)
    expect(page).to have_content(vacancy.job_title)
  end

  scenario 'clicking on more information should not increment the counter' do
    vacancy = create(:vacancy, school: school, status: 'published')
    visit school_job_path(vacancy.id)

    expect { click_on 'Get more information' }.to change { vacancy.get_more_info_counter.to_i }.by(0)
  end
end
