require 'rails_helper'

RSpec.feature 'When hiring staff specify a part time role' do
  scenario 'the create job form should warn hiring staff to enter a pro rata salary for part time roles' do
    school = create(:school)
    stub_hiring_staff_auth(urn: school.urn)

    visit new_school_job_path

    expect(page).to have_content(I18n.t('jobs.form_hints.pro_rata_warning'))
  end

  scenario 'the edit job form should warn hiring staff to enter a pro rata salary' do
    school = create(:school)
    stub_hiring_staff_auth(urn: school.urn)
    vacancy = create(:vacancy, :published, school: school)

    visit edit_school_job_path(vacancy.id)

    click_link_in_container_with_text('Job title')

    expect(page).to have_content(I18n.t('jobs.form_hints.pro_rata_warning'))
  end

  scenario 'the list page should indicate a pro rata salary', elasticsearch: true do
    create(:vacancy, working_pattern: :part_time)

    Vacancy.__elasticsearch__.client.indices.flush

    visit jobs_path

    expect(page.find('.vacancy:eq(1)')).to have_content('Part time')
    expect(page.find('.vacancy:eq(1)')).to have_content(I18n.t('jobs.per_year_pro_rata'))
  end

  scenario 'the list page should not indicate a pro rata salary if the role is full time', elasticsearch: true do
    create(:vacancy, working_pattern: :full_time)

    Vacancy.__elasticsearch__.client.indices.flush

    visit jobs_path

    expect(page.find('.vacancy:eq(1)')).to have_content('Full time')
    expect(page.find('.vacancy:eq(1)')).to have_content(I18n.t('jobs.per_year'))
    expect(page.find('.vacancy:eq(1)')).not_to have_content(I18n.t('jobs.per_year_pro_rata'))
  end

  scenario 'a job page should indicate a pro rata salary if the role is part time' do
    school = create(:school)
    vacancy = create(:vacancy, :published, school: school, working_pattern: :part_time)

    visit job_path(vacancy.id)

    within('.vacancy--metadata') { expect(page).to have_content('pro rata') }
  end

  scenario 'a job page should not indicate a pro rata salary if the role is full time' do
    school = create(:school)
    vacancy = create(:vacancy, :published, school: school, working_pattern: :full_time)

    visit job_path(vacancy.id)

    within('.vacancy--metadata') { expect(page).not_to have_content('pro rata') }
  end

  context 'and the user is on mobile' do
    scenario 'a job page should indicate a pro rata salary if the role is part time' do
      page.driver.header('User-Agent', USER_AGENTS['MOBILE_CHROME'])
      school = create(:school)
      vacancy = create(:vacancy, :published, school: school, working_pattern: :part_time)

      visit job_path(vacancy.id)

      within('.vacancy table.check-your-answers') { expect(page).to have_content('pro rata') }
    end

    scenario 'a job page should not indicate a pro rata salary if the role is full time' do
      page.driver.header('User-Agent', USER_AGENTS['MOBILE_CHROME'])
      school = create(:school)
      vacancy = create(:vacancy, :published, school: school, working_pattern: :full_time)

      visit job_path(vacancy.id)

      within('.vacancy table.check-your-answers') { expect(page).not_to have_content('pro rata') }
    end
  end

  scenario 'a job edit page should indicate a pro rata salary if the role is part time' do
    school = create(:school)
    stub_hiring_staff_auth(urn: school.urn)
    vacancy = create(:vacancy, :published, school: school, working_pattern: :part_time)

    visit edit_school_job_path(vacancy.id)

    expect(page).to have_content('pro rata')
  end

  scenario 'a job edit page should not indicate a pro rata salary if the role is full time' do
    school = create(:school)
    stub_hiring_staff_auth(urn: school.urn)
    vacancy = create(:vacancy, :published, school: school, working_pattern: :full_time)

    visit edit_school_job_path(vacancy.id)

    expect(page).not_to have_content('pro rata')
  end
end
