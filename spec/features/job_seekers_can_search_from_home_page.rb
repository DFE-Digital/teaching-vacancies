require 'rails_helper'

RSpec.feature 'Searching on the home page' do
  before do
    visit root_path
    within '.search_panel' do
      fill_in 'jobs_search_form[keyword]', with: 'math'
      fill_in 'jobs_search_form[location]', with: 'bristol'

      # Click 'Add more filters'
      find('.new_jobs_search_form > details').click

      check I18n.t('jobs.job_role_options.nqt_suitable'),
            name: 'jobs_search_form[job_roles][]',
            visible: false
      # Uncomment once we include education phase on the search filters
      # check I18n.t('jobs.education_phase_options.primary'),
      #       name: 'jobs_search_form[phases][]',
      #       visible: false
      check I18n.t('jobs.working_pattern_options.part_time'),
            name: 'jobs_search_form[working_patterns][]',
            visible: false
      check I18n.t('jobs.working_pattern_options.full_time'),
            name: 'jobs_search_form[working_patterns][]',
            visible: false

      page.find('.govuk-button[type=submit]').click
    end
  end

  scenario 'search terms and filter selections are persisted onto the jobs index page' do
    expect(page.current_path).to eq(jobs_path)
    expect(find_field('jobs_search_form[keyword]').value).to eq 'math'
    expect(find_field('jobs_search_form[location]').value).to eq 'bristol'
    expect(page).to have_css('.moj-filter__tag', count: 3)
    expect(page.find('#jobs-search-form-job-roles-nqt-suitable-field')).to be_checked
    # expect(page.find('#jobs-search-form-education-phases-primary-field')).to be_checked
    # expect(page.find('#jobs-search-form-education-phases-secondary-field')).not_to be_checked
    expect(page.find('#jobs-search-form-working-patterns-part-time-field')).to be_checked
    expect(page.find('#jobs-search-form-working-patterns-full-time-field')).to be_checked
  end
end
