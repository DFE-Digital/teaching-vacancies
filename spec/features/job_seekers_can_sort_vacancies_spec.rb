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

    scenario 'Default view is to be sorted by most recent listings' do
      expect(page.find('.vacancy:nth-child(1)')).to have_content(first_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(2)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(3)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(4)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(5)')).to have_content(fifth_vacancy.job_title)
    end

    scenario 'Can be sorted by oldest listings when option is selected' do
      select I18n.t('jobs.sort_by_most_ancient')
      click_button I18n.t('jobs.sort_submit')

      expect(page).to have_select(I18n.t('jobs.sort_by'), selected: I18n.t('jobs.sort_by_most_ancient'))
      expect(page.find('.vacancy:nth-child(1)')).to have_content(fifth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(2)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(3)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(4)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(5)')).to have_content(first_vacancy.job_title)
    end

    scenario 'Can be sorted by soonest expiry date and time when option is selected' do
      select I18n.t('jobs.sort_by_earliest_closing_date')
      click_button I18n.t('jobs.sort_submit')

      expect(page).to have_select(I18n.t('jobs.sort_by'), selected: I18n.t('jobs.sort_by_earliest_closing_date'))
      expect(page.find('.vacancy:nth-child(1)')).to have_content(fifth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(2)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(3)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(4)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(5)')).to have_content(first_vacancy.job_title)
    end

    scenario 'Can be sorted by furthest expiry date and time when option is selected' do
      select I18n.t('jobs.sort_by_furthest_closing_date')
      click_button I18n.t('jobs.sort_submit')

      expect(page).to have_select(I18n.t('jobs.sort_by'), selected: I18n.t('jobs.sort_by_furthest_closing_date'))
      expect(page.find('.vacancy:nth-child(1)')).to have_content(first_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(2)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(3)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(4)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(5)')).to have_content(fifth_vacancy.job_title)
    end

    scenario 'Just selecting a dropdown option, sorts the page in javascript enabled browsers', js: true do
      select I18n.t('jobs.sort_by_furthest_closing_date')
      # In JS enabled browsers, the sort button is hidden.
      # When a dropdown option is selected, the form is submitted using Javascript.

      expect(page).to have_select(I18n.t('jobs.sort_by'), selected: I18n.t('jobs.sort_by_furthest_closing_date'))
      expect(page.find('.vacancy:nth-child(1)')).to have_content(first_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(2)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(3)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(4)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(5)')).to have_content(fifth_vacancy.job_title)
    end

    scenario 'Can be resorted by most recent listing when option is selected' do
      select I18n.t('jobs.sort_by_earliest_closing_date')
      click_button I18n.t('jobs.sort_submit')

      select I18n.t('jobs.sort_by_most_recent')
      click_button I18n.t('jobs.sort_submit')

      expect(page).to have_select(I18n.t('jobs.sort_by'), selected: I18n.t('jobs.sort_by_most_recent'))
      expect(page.find('.vacancy:nth-child(1)')).to have_content(first_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(2)')).to have_content(third_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(3)')).to have_content(second_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(4)')).to have_content(fourth_vacancy.job_title)
      expect(page.find('.vacancy:nth-child(5)')).to have_content(fifth_vacancy.job_title)
    end
  end
end
