require 'support/browser_test_helper'
require 'support/i18n_helper'

RSpec.describe 'Page availability', js: true, smoke_test: true do
  context 'Job seeker visits vacancy page' do
    it 'should ensure users can search and view a job vacancy page' do
      page = Capybara::Session.new(:poltergeist)
      page.driver.set_cookie('smoke_test', '1', domain: 'teaching-vacancies.service.gov.uk')

      page.visit 'https://teaching-vacancies.service.gov.uk/'
      expect(page).to have_content(I18n.t('jobs.heading'))

      page.fill_in I18n.t('jobs.filters.keyword'), with: 'Maths', visible: false
      page.first('.govuk-button[type=submit]').click

      expect(page).to have_content(I18n.t('subscriptions.link.text'))

      vacancy_page = page.first('.view-vacancy-link')
      unless vacancy_page.nil?
        vacancy_page.click
        expect(page).to have_content(I18n.t('jobs.job_summary'))
        expect(page.current_url).to include('https://teaching-vacancies.service.gov.uk/jobs/')
      end
    end
  end
end
