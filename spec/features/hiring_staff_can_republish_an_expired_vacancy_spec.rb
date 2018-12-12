require 'rails_helper'
RSpec.feature 'Republishing an expired vacancy' do
  let(:school) { create(:school) }
  let(:session_id) { SecureRandom.uuid }
  let(:vacancy) do
    build(:vacancy,
          school: school,
          status: 'published',
          expires_on: Faker::Time.backward(6),
          publish_on: Faker::Time.backward(10))
  end

  before(:each) do
    stub_hiring_staff_auth(urn: school.urn, session_id: session_id)
    vacancy.send :set_slug
    vacancy.save(validate: false)
  end

  scenario 'hiring staff can see a Republish link for an expired vacancy' do
    visit school_path

    table = page.find('section#expired-jobs table')
    expect(table).to have_selector('td', text: vacancy.job_title)
    expect(table).to have_selector('td', text: 'Republish')
  end

  scenario 'the republish form pre-fills dates in the job listing' do
    visit new_school_job_republish_path(vacancy.id)
    expires_on = vacancy.expires_on
    expires_on_dd = page.find('input#republish_form_expires_on_dd')
    expires_on_mm = page.find('input#republish_form_expires_on_mm')
    expires_on_yyyy = page.find('input#republish_form_expires_on_yyyy')

    expect(expires_on_dd.value).to eq(expires_on.strftime('%-d'))
    expect(expires_on_mm.value).to eq(expires_on.strftime('%-m'))
    expect(expires_on_yyyy.value).to eq(expires_on.strftime('%Y'))
  end

  scenario 'the republish form has instructions to the hiring staff' do
    visit new_school_job_republish_path(vacancy.id)

    expect(page).to have_content(I18n.t('jobs.republish_instructions'))
  end

  context 'the hiring staff enters invalid dates' do
    scenario 'the republish form shows validation errors if publish_on is before today' do
      visit new_school_job_republish_path(vacancy.id)

      yesterday = Time.zone.yesterday
      tomorrow = Time.zone.tomorrow

      fill_in('republish_form[publish_on_dd]', with: yesterday.day)
      fill_in('republish_form[publish_on_mm]', with: yesterday.month)
      fill_in('republish_form[publish_on_yyyy]', with: yesterday.year)

      fill_in('republish_form[expires_on_dd]', with: tomorrow.day)
      fill_in('republish_form[expires_on_mm]', with: tomorrow.month)
      fill_in('republish_form[expires_on_yyyy]', with: tomorrow.year)

      click_on('Save and continue')

      expect(page).to have_content(I18n.t('activerecord.errors.models.vacancy.attributes.publish_on.before_today'))
    end

    scenario 'the republish form shows validation errors if expires_on is before publish_on' do
      visit new_school_job_republish_path(vacancy.id)

      today = Time.zone.today
      tomorrow = Time.zone.tomorrow

      fill_in('republish_form[publish_on_dd]', with: tomorrow.day)
      fill_in('republish_form[publish_on_mm]', with: tomorrow.month)
      fill_in('republish_form[publish_on_yyyy]', with: tomorrow.year)

      fill_in('republish_form[expires_on_dd]', with: today.day)
      fill_in('republish_form[expires_on_mm]', with: today.month)
      fill_in('republish_form[expires_on_yyyy]', with: today.year)

      click_on('Save and continue')

      expect(page).to have_content(
        I18n.t('activerecord.errors.models.vacancy.attributes.expires_on.before_publish_date')
      )
    end
  end

  context 'the hiring staff enters valid dates' do
    scenario 'the hiring staff can republish the job successfully' do
      visit new_school_job_republish_path(vacancy.id)

      today = Time.zone.today
      tomorrow = Time.zone.tomorrow

      fill_in('republish_form[publish_on_dd]', with: today.day)
      fill_in('republish_form[publish_on_mm]', with: today.month)
      fill_in('republish_form[publish_on_yyyy]', with: today.year)

      fill_in('republish_form[expires_on_dd]', with: tomorrow.day)
      fill_in('republish_form[expires_on_mm]', with: tomorrow.month)
      fill_in('republish_form[expires_on_yyyy]', with: tomorrow.year)

      click_on('Save and continue')

      expect(page).to_not have_content(I18n.t('jobs.already_published'))
      expect(page).to have_content(I18n.t('jobs.confirmation_page.submitted'))
    end
  end
end
