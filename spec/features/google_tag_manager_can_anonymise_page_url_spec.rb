require 'rails_helper'

RSpec.feature 'Google Tag Manager' do
  context 'When searching for jobs with home postcode filter' do
    scenario 'parameters are removed from URL before sending URL to dataLayer', js: true do
      visit jobs_path

      within '.filters-form' do
        fill_in 'location', with: 'CH52DD'
        select '5 miles'
        page.find('.govuk-button[type=submit]').click
      end

      expect(evaluate_script('dataLayer')).to include(include('event' => 'parametersRemoved', 'dePIIedURL' => '/jobs'))
    end
  end
end
