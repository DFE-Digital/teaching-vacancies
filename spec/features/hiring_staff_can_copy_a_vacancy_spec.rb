require 'rails_helper'
RSpec.feature 'Copying a vacancy' do
  let(:school) { create(:school) }

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
  end

  scenario 'a job can be successfully copied and published' do
    original_vacancy = FactoryBot.build(:vacancy, :past_publish, school: school)
    original_vacancy.save(validate: false) # Validation prevents publishing on a past date

    new_vacancy = original_vacancy.dup
    new_vacancy.job_title = 'A new job title'
    new_vacancy.starts_on = 35.days.from_now
    new_vacancy.ends_on = 100.days.from_now
    new_vacancy.publish_on = 0.days.from_now
    new_vacancy.expires_on = 30.days.from_now

    visit school_path

    within('table.vacancies') do
      click_on I18n.t('jobs.copy_link')
    end

    expect(page).to have_content(I18n.t('jobs.copy_page_title', job_title: original_vacancy.job_title))
    within('form.copy-form') do
      fill_in_copy_vacancy_form_fields(new_vacancy)
      click_on I18n.t('buttons.save_and_continue')
    end

    expect(page).to have_content(I18n.t('jobs.review_heading', school: school.name))
    click_on I18n.t('jobs.submit')

    expect(page).to have_content(I18n.t('jobs.confirmation_page.submitted'))
    click_on('Preview your job listing')

    expect(page).to have_content(new_vacancy.job_title)
    expect(page).to have_content(new_vacancy.starts_on)
    expect(page).to have_content(new_vacancy.ends_on)
    expect(page).to have_content(new_vacancy.publish_on)
    expect(page).to have_content(new_vacancy.expires_on)

    expect(page).not_to have_content(original_vacancy.job_title)
    expect(page).not_to have_content(original_vacancy.starts_on)
    expect(page).not_to have_content(original_vacancy.ends_on)
    expect(page).not_to have_content(original_vacancy.publish_on)
    expect(page).not_to have_content(original_vacancy.expires_on)
  end

  # scenario 'a job can be successfully copied and published' do
  #   FactoryBot.create(:vacancy, school: school)
  #
  #   visit school_path
  #
  #   click_on I18n.t('jobs.duplicate_link')
  #   click_on I18n.t('jobs.submit')
  #
  #   expect(page).to have_content(I18n.t('jobs.confirmation_page.submitted'))
  # end
  #
  # scenario 'hiring staff can see a Duplicate link on published jobs' do
  #   FactoryBot.create(:vacancy, school: school)
  #
  #   visit school_path
  #
  #   expect(page).to have_selector('td', text: I18n.t('jobs.duplicate_link'))
  # end
  #
  # scenario 'hiring staff can see a Duplicate link on pending jobs' do
  #   vacancy = FactoryBot.build(:vacancy, :future_publish)
  #   vacancy.school = school
  #   vacancy.save
  #
  #   visit jobs_with_type_school_path(:pending)
  #
  #   expect(page).to have_selector('td', text: I18n.t('jobs.duplicate_link'))
  # end
  #
  # scenario 'hiring staff can NOT see a Duplicate link on draft jobs' do
  #   vacancy = FactoryBot.build(:vacancy, :draft)
  #   vacancy.school = school
  #   vacancy.save
  #
  #   visit jobs_with_type_school_path(:draft)
  #
  #   expect(page).to_not have_selector('td', text: I18n.t('jobs.duplicate_link'))
  # end
  #
  # context 'review page' do
  #   context 'copying a published job' do
  #     scenario 'the job title is updated to show it is a copy' do
  #       published = FactoryBot.create(:vacancy, school: school)
  #
  #       visit jobs_with_type_school_path(:published)
  #       click_on I18n.t('jobs.duplicate_link')
  #
  #       expect(page).to have_content("#{I18n.t('jobs.copy_of')} #{published.job_title}")
  #     end
  #
  #     scenario 'the publish_on date is updated to today' do
  #       published = FactoryBot.build(:vacancy, :past_publish)
  #       published.school = school
  #       published.save(validate: false)
  #
  #       visit school_path
  #       click_on I18n.t('jobs.duplicate_link')
  #
  #       dt_publish_on = page.find('dt#publish_on')
  #       expect(dt_publish_on.sibling('dd.app-check-your-answers__answer')).to_not have_content(published.publish_on)
  #       expect(dt_publish_on.sibling('dd.app-check-your-answers__answer')).to have_content(Time.zone.today)
  #     end
  #   end
  #
  #   context 'copying a pending job' do
  #     scenario 'the job title is updated to show it is a copy' do
  #       pending = FactoryBot.build(:vacancy, :future_publish)
  #       pending.school = school
  #       pending.save
  #
  #       visit jobs_with_type_school_path(:pending)
  #       click_on I18n.t('jobs.duplicate_link')
  #
  #       expect(page).to have_content("#{I18n.t('jobs.copy_of')} #{pending.job_title}")
  #     end
  #   end
  # end
end
