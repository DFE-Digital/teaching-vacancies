require 'rails_helper'

RSpec.feature 'Viewing the home page' do
  before { visit page_path(:home) }

  scenario 'searching from the blue box lands on the jobs index page' do
    within '.search_panel' do
      fill_in 'location', with: 'bristol'
      fill_in 'subject', with: 'math'
      fill_in 'job_title', with: 'head teacher'
      check 'Primary', name: 'phases[]'
      check 'Secondary', name: 'phases[]'

      page.find('.govuk-button[type=submit]').click
    end

    expect(page.current_path).to eq(jobs_path)

    expect(find_field('location').value).to eq 'bristol'
    expect(find_field('subject').value).to eq 'math'
    expect(find_field('job_title').value).to eq 'head teacher'
    expect(page).to have_field('phases_primary', checked: true)
    expect(page).to have_field('phases_secondary', checked: true)
    expect(page).to have_field('phases_not_applicable', checked: false)
  end
end
