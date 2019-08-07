require 'rails_helper'

RSpec.feature 'Running a Google Optimize experiment', js: true do
  context 'When job seeker visits a page' do
    scenario 'google optimize should be activated' do
      visit jobs_path

      expect(evaluate_script('dataLayer')).to include(include('event' => 'optimize.activate'))
    end
  end
end