require 'rails_helper'

RSpec.feature 'Sorting vacancies' do
  context 'when sorting the vacancy listings', elasticsearch: true do
    before { skip_vacancy_publish_on_validation }

    let!(:first_vacancy) { create(:vacancy, :published, expires_on: 7.days.from_now, publish_on: 4.days.ago) }
    let!(:second_vacancy) { create(:vacancy, :published, expires_on: 6.days.from_now, publish_on: 10.days.ago) }
    let!(:third_vacancy) { create(:vacancy, :published, expires_on: 5.days.from_now, publish_on: 8.days.ago) }

    let!(:fourth_vacancy) do
      create(:vacancy,
             :published,
             expires_on: 5.days.from_now,
             expiry_time: Time.zone.now + 5.days + 2.hours,
             publish_on: 10.days.ago)
    end

    let!(:fifth_vacancy) do
      create(:vacancy,
             :published,
             expires_on: 5.days.from_now,
             expiry_time: Time.zone.now + 5.days + 1.hour,
             publish_on: 10.days.ago)
    end

    before do
      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path
    end

    scenario 'Default view is to be sorted by closest expiry date and time' do
      expect(page.find('.vacancy:eq(1)')).to have_content(fifth_vacancy.job_title)
      expect(page.find('.vacancy:eq(2)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:eq(3)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:eq(4)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:eq(5)')).to have_content(first_vacancy.job_title)
    end

    scenario 'Can be sorted by most recent listing when option is selected' do
      select I18n.t('jobs.latest_posting')
      click_button I18n.t('jobs.sort_submit')

      expect(page).to have_select(I18n.t('jobs.sort_by'), selected: I18n.t('jobs.latest_posting'))
      expect(page.find('.vacancy:eq(1)')).to have_content(first_vacancy.job_title)
      expect(page.find('.vacancy:eq(2)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:eq(3)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:eq(4)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:eq(5)')).to have_content(fifth_vacancy.job_title)
    end

    scenario 'Can be sorted by oldest listings when option is selected' do
      select I18n.t('jobs.oldest_posting')
      click_button I18n.t('jobs.sort_submit')

      expect(page).to have_select(I18n.t('jobs.sort_by'), selected: I18n.t('jobs.oldest_posting'))
      expect(page.find('.vacancy:eq(1)')).to have_content(fifth_vacancy.job_title)
      expect(page.find('.vacancy:eq(2)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:eq(3)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:eq(4)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:eq(5)')).to have_content(first_vacancy.job_title)
    end

    scenario 'Can be resorted by soonest expiry date and time when option is selected' do
      select I18n.t('jobs.latest_posting')
      click_button I18n.t('jobs.sort_submit')

      select I18n.t('jobs.closes_soon')
      click_button I18n.t('jobs.sort_submit')

      expect(page).to have_select(I18n.t('jobs.sort_by'), selected: I18n.t('jobs.closes_soon'))
      expect(page.find('.vacancy:eq(1)')).to have_content(fifth_vacancy.job_title)
      expect(page.find('.vacancy:eq(2)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:eq(3)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:eq(4)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:eq(5)')).to have_content(first_vacancy.job_title)
    end

    scenario 'Can be sorted by furthest expiry date and time when option is selected' do
      select I18n.t('jobs.closes_later')
      click_button I18n.t('jobs.sort_submit')

      expect(page).to have_select(I18n.t('jobs.sort_by'), selected: I18n.t('jobs.closes_later'))
      expect(page.find('.vacancy:eq(1)')).to have_content(first_vacancy.job_title)
      expect(page.find('.vacancy:eq(2)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:eq(3)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:eq(4)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:eq(5)')).to have_content(fifth_vacancy.job_title)
    end
  end
end
