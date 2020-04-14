require 'rails_helper'

RSpec.feature 'Viewing the home page' do
  before { visit page_path(:home) }

  scenario 'searching from the blue box lands on the jobs index page', elasticsearch: true do
    within '.search_panel' do
      fill_in 'location', with: 'bristol'
      fill_in 'keyword', with: 'math'

      page.find('.govuk-button[type=submit]').click
    end

    expect(page.current_path).to eq(jobs_path)

    expect(find_field('location').value).to eq 'bristol'
    expect(find_field('keyword').value).to eq 'math'
  end

  context 'request headers' do
    scenario 'should not have a noindex header on the home page when visiting the root path' do
      visit root_path
      expect(response_headers['X-Robots-Tag']).to_not include('noindex')
    end
  end
end
