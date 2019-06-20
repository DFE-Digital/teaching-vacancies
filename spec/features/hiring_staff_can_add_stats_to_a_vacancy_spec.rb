require 'rails_helper'
require 'sanitize'
RSpec.feature 'Submitting effectiveness feedback on expired vacancies', js: true do
  NOTIFICATION_BADGE_SELECTOR = "[data-test='expired-vacancies-with-feedback-outstanding']".freeze
  JOB_TITLE_LINK_SELECTOR = '#job-title.view-vacancy-link'.freeze
  AWAITING_FEEDBACK_NOTICE_SELECTOR = '#awaiting_notice .count'.freeze

  let(:school) { create(:school) }
  before(:each) do
    stub_hiring_staff_auth(urn: school.urn)
    create(:vacancy, :published_slugged, school: school)
  end

  context 'when there are vacancies awaiting feedback' do
    let!(:vacancy) { create(:vacancy, :expired, school: school) }
    let!(:another_vacancy) { create(:vacancy, :expired, school: school) }
    let!(:third_vacancy) { create(:vacancy, :expired, school: school) }

    scenario 'hiring staff can see notification badge' do
      visit school_path

      expect(page).to have_selector(NOTIFICATION_BADGE_SELECTOR, text: 3)
    end

    scenario 'hiring staff can see notice of vacancies awaiting feedback' do
      visit school_path

      expect(page).to have_selector(AWAITING_FEEDBACK_NOTICE_SELECTOR, text: '3 jobs')
    end

    scenario 'feedback can be added to any number of vacancies' do
      visit jobs_with_type_school_path(type: :awaiting_feedback)

      expect(page).to have_selector(JOB_TITLE_LINK_SELECTOR, count: 3)
      expect(page).to have_selector(JOB_TITLE_LINK_SELECTOR, text: vacancy.job_title)
      expect(page).to have_selector(JOB_TITLE_LINK_SELECTOR, text: another_vacancy.job_title)
      expect(page).to have_selector(JOB_TITLE_LINK_SELECTOR, text: third_vacancy.job_title)

      within('tr', text: vacancy.job_title) do
        select I18n.t('jobs.feedback.hired_status.hired_tvs'), from: 'vacancy_hired_status'
        select I18n.t('jobs.feedback.listed_elsewhere.listed_paid'), from: 'vacancy_listed_elsewhere'
        click_on I18n.t('buttons.submit')
      end

      expect(page).to have_content(I18n.t('jobs.feedback_submitted'))
      expect(page).to_not have_content(vacancy.job_title)

      expect(page).to have_selector(AWAITING_FEEDBACK_NOTICE_SELECTOR, text: '2 jobs')

      vacancy.reload

      expect(vacancy.hired_status).to eq('hired_tvs')
      expect(vacancy.listed_elsewhere).to eq('listed_paid')

      within('tr', text: another_vacancy.job_title) do
        select I18n.t('jobs.feedback.hired_status.hired_other_free'), from: 'vacancy_hired_status'
        select I18n.t('jobs.feedback.listed_elsewhere.listed_free'), from: 'vacancy_listed_elsewhere'
        click_on I18n.t('buttons.submit')
      end

      expect(page).to have_content(I18n.t('jobs.feedback_submitted'))
      expect(page).to_not have_content(vacancy.job_title)

      expect(page).to have_selector(AWAITING_FEEDBACK_NOTICE_SELECTOR, text: '1 job')

      another_vacancy.reload

      expect(another_vacancy.hired_status).to eq('hired_other_free')
      expect(another_vacancy.listed_elsewhere).to eq('listed_free')
    end

    scenario 'when an option is not selected in a javascript disabled browser', js: false do
      visit jobs_with_type_school_path(type: :awaiting_feedback)

      within('tr', text: vacancy.job_title) do
        select I18n.t('jobs.feedback.hired_status.hired_tvs'), from: 'vacancy_hired_status'
        click_on I18n.t('buttons.submit')
      end

      expect(page).to have_content(I18n.t('jobs.feedback_error'))
      expect(page).to have_content(vacancy.job_title)

      expect(page).to_not have_content(I18n.t('jobs.inline_feedback_error'))

      expect(vacancy.hired_status).to eq(nil)
      expect(vacancy.listed_elsewhere).to eq(nil)
    end

    scenario 'when an option is not selected in a javascript enabled browser' do
      visit jobs_with_type_school_path(type: :awaiting_feedback)

      within('tr', text: vacancy.job_title) do
        select I18n.t('jobs.feedback.hired_status.hired_tvs'), from: 'vacancy_hired_status'
        click_on I18n.t('buttons.submit')
      end

      expect(page).to have_content(I18n.t('jobs.inline_feedback_error'))
      expect(page).to have_content(vacancy.job_title)

      expect(page).to_not have_content(I18n.t('jobs.feedback_error'))

      expect(vacancy.hired_status).to eq(nil)
      expect(vacancy.listed_elsewhere).to eq(nil)
    end

    scenario 'input error styling only displays on blank selection field(s)' do
      visit jobs_with_type_school_path(type: :awaiting_feedback)

      within('tr', text: vacancy.job_title) do
        click_on I18n.t('buttons.submit')
      end

      expect(page).to have_content(I18n.t('jobs.inline_feedback_error'), count: 2)

      within('tr', text: vacancy.job_title) do
        select I18n.t('jobs.feedback.hired_status.hired_tvs'), from: 'vacancy_hired_status'
        click_on I18n.t('buttons.submit')

        select '--', from: 'vacancy_hired_status'

        select I18n.t('jobs.feedback.listed_elsewhere.listed_paid'), from: 'vacancy_listed_elsewhere'
        click_on I18n.t('buttons.submit')
      end

      expect(page).to have_content(I18n.t('jobs.inline_feedback_error'), count: 1)
    end

    scenario 'When all feedback has been submitted' do
      visit jobs_with_type_school_path(type: :awaiting_feedback)

      expect(page).to have_selector(JOB_TITLE_LINK_SELECTOR, count: 3)
      expect(page).to have_selector(JOB_TITLE_LINK_SELECTOR, text: vacancy.job_title)
      expect(page).to have_selector(JOB_TITLE_LINK_SELECTOR, text: another_vacancy.job_title)
      expect(page).to have_selector(JOB_TITLE_LINK_SELECTOR, text: third_vacancy.job_title)

      within('tr', text: vacancy.job_title) do
        select I18n.t('jobs.feedback.hired_status.hired_tvs'), from: 'vacancy_hired_status'
        select I18n.t('jobs.feedback.listed_elsewhere.listed_paid'), from: 'vacancy_listed_elsewhere'
        click_on I18n.t('buttons.submit')
      end

      within('tr', text: another_vacancy.job_title) do
        select I18n.t('jobs.feedback.hired_status.not_filled_ongoing'), from: 'vacancy_hired_status'
        select I18n.t('jobs.feedback.listed_elsewhere.listed_dont_know'), from: 'vacancy_listed_elsewhere'
        click_on I18n.t('buttons.submit')
      end

      within('tr', text: third_vacancy.job_title) do
        select I18n.t('jobs.feedback.hired_status.not_filled_ongoing'), from: 'vacancy_hired_status'
        select I18n.t('jobs.feedback.listed_elsewhere.listed_mix'), from: 'vacancy_listed_elsewhere'
        click_on I18n.t('buttons.submit')
      end

      expect(page).to have_content(Sanitize.clean(I18n.t('jobs.feedback_all_submitted')))
      expect(page).to_not have_content(I18n.t('jobs.awaiting_feedback_intro'))
    end
  end

  context 'when there are no vacancies awaiting feedback' do
    scenario 'hiring staff can not see notification badge' do
      visit jobs_with_type_school_path(type: :awaiting_feedback)

      expect(page).to_not have_selector(NOTIFICATION_BADGE_SELECTOR)
      expect(page).to have_content(I18n.t('jobs.no_awaiting_feedback'))
    end
  end
end
