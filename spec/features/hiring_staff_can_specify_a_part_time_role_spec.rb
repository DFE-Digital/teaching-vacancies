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
end
