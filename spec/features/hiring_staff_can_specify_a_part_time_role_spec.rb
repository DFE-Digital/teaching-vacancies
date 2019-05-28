require 'rails_helper'

RSpec.feature 'When hiring staff specify a part time role' do
  scenario 'the create job form should warn hiring staff to enter a full time equivalent salary' do
    school = create(:school)
    stub_hiring_staff_auth(urn: school.urn)

    visit new_school_job_path

    expect(page).to have_content(I18n.t('jobs.form_warnings.fte_salary'))
  end

  context 'and the vacancy has FTE salary' do
    scenario 'the edit job form should warn hiring staff to enter a full time equivalent salary' do
      school = create(:school)
      stub_hiring_staff_auth(urn: school.urn)
      vacancy = create(:vacancy, :published, school: school, working_patterns: ['part_time'])

      visit edit_school_job_path(vacancy.id)

      click_link_in_container_with_text('Job title')

      expect(page).to have_content(I18n.t('jobs.form_warnings.fte_salary'))
    end
  end

  context 'and the vacancy has pro rata salary' do
    scenario 'the edit job form should warn hiring staff to enter a pro rata salary for part time jobs' do
      school = create(:school)
      stub_hiring_staff_auth(urn: school.urn)
      vacancy = create(:vacancy, :published, school: school, working_patterns: ['part_time'], pro_rata_salary: true)

      visit edit_school_job_path(vacancy.id)

      click_link_in_container_with_text('Job title')

      expect(page).to have_content(I18n.t('jobs.form_warnings.pro_rata_salary'))
    end
  end
end
