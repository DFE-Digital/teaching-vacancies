require 'rails_helper'
RSpec.feature 'Viewing vacancies' do
  scenario 'Vacancies are listed with summary information', elasticsearch: true do
    vacancy = create(:vacancy)
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    verify_vacancy_list_page_details(VacancyPresenter.new(vacancy))
  end

  scenario 'There are enough vacancies to invoke pagination', elasticsearch: true do
    job_count = Vacancy.default_per_page + 1 # must be larger than the default page limit
    create_list(:vacancy, job_count)

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    expect(page).to have_content("There are #{job_count} jobs listed.")
    expect(page).to have_selector('.vacancy', count: Vacancy.default_per_page)
  end

  scenario 'Only vacancies satisfying all publishing conditions are listed', elasticsearch: true do
    valid_vacancy = create(:vacancy)

    expired = build(:vacancy, :expired)
    expired.send :set_slug
    expired.save(validate: false)
    [:trashed, :draft,
     %i[trashed], %i[draft]].each { |args| create(:vacancy, *args) }
    create(:vacancy, :published, publish_on: Time.zone.tomorrow)
    already_published = build(:vacancy, :published, publish_on: Time.zone.yesterday)
    already_published.send :set_slug
    already_published.save(validate: false)

    visit jobs_path

    expect(page).to have_content(valid_vacancy.job_title)
    expect(page).to have_content(already_published.job_title)
    expect(page).to have_selector('.vacancy', count: 2)
  end

  scenario 'Vacancies should not paginate when under per-page limit', elasticsearch: true do
    allow(Vacancy).to receive(:default_per_page).and_return(2)
    vacancies = create_list(:vacancy, 2)

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    vacancies.each { |v| expect(page).to have_content(v.job_title) }
    expect(page).to have_no_link('2')
  end

  scenario 'Vacancies should paginate when over per-page limit', elasticsearch: true do
    allow(Vacancy).to receive(:default_per_page).and_return(2)

    skip_vacancy_publish_on_validation

    first_vacancy = create(:vacancy, :published, publish_on: 4.days.ago)
    second_vacancy = create(:vacancy, :published, publish_on: 5.days.ago)
    third_vacancy = create(:vacancy, :published, publish_on: 9.days.ago)

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    expect(page).to have_content(first_vacancy.job_title)
    expect(page).to have_content(second_vacancy.job_title)
    expect(page).to_not have_content(third_vacancy.job_title)

    expect(page).to have_link('2')
  end

  scenario 'Should correctly singularize when one vacancy is returned by a search', elasticsearch: true do
    vacancies = create_list(:vacancy, 1, subject: create(:subject, name: 'English'))
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path
    within '.filters-form' do
      fill_in 'subject', with: 'English'
      page.find('.govuk-button[type=submit]').click
    end
    expect(page).to have_content(I18n.t('jobs.job_count', count: vacancies.count))
  end

  scenario 'Should correctly pluralize the number of vacancies returned by a search', elasticsearch: true do
    vacancies = create_list(:vacancy, 3, subject: create(:subject, name: 'English'))
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path
    within '.filters-form' do
      fill_in 'subject', with: 'English'
      page.find('.govuk-button[type=submit]').click
    end
    expect(page).to have_content(I18n.t('jobs.job_count_plural', count: vacancies.count))
  end

  scenario 'Should correctly singularize the number of vacancies returned without a search', elasticsearch: true do
    vacancies = create_list(:vacancy, 1)
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path
    expect(page).to have_content(I18n.t('jobs.job_count_without_search', count: vacancies.count))
  end

  scenario 'Should correctly pluralize the number of vacancies returned without a search', elasticsearch: true do
    vacancies = create_list(:vacancy, 3)
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path
    expect(page).to have_content(I18n.t('jobs.job_count_plural_without_search', count: vacancies.count))
  end

  scenario 'Should advise users to widen their search when no results are returned' do
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      fill_in 'subject', with: 'English'
      click_on I18n.t('buttons.apply_filters')
    end

    I18n.t('jobs.no_jobs').each do |sentence|
      expect(page).to have_content(sentence)
    end
  end

  scenario 'Should advise users to check back soon when no jobs are listed' do
    visit jobs_path

    I18n.t('jobs.none_listed', count: Vacancy.listed.count).each do |sentence|
      expect(page).to have_content(sentence)
    end
    expect(page).not_to have_content(I18n.t('jobs.no_jobs'))
  end

  context 'when a page number is manually added to the URL which does not return results' do
    scenario 'should render the last page of results instead the of the no results copy', elasticsearch: true do
      create_list(:vacancy, 11, :published)
      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path(page: 99)

      expect(page).to have_content(I18n.t('jobs.job_count_plural_without_search', count: 11))

      within('.pagination') do
        within('.current') do
          expect(page).to have_content('2')
        end
      end

      I18n.t('jobs.none_listed', count: Vacancy.listed.count).each do |sentence|
        expect(page).not_to have_content(sentence)
      end
    end
  end

  scenario 'Should not show text warning about zero jobs on the site if jobs exist but are filtered out' do
    visit jobs_path

    create(:vacancy, :published, job_title: 'Headmaster')
    create(:vacancy, :published, job_title: 'Languages Teacher')

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      fill_in 'subject', with: 'Maths'
      click_button('Search')
    end

    I18n.t('jobs.no_jobs').each do |sentence|
      expect(page).to have_content(sentence)
    end

    I18n.t('jobs.none_listed').each do |sentence|
      expect(page).not_to have_content(sentence)
    end

    click_button('Refine search')

    I18n.t('jobs.no_jobs').each do |sentence|
      expect(page).to have_content(sentence)
    end

    I18n.t('jobs.none_listed').each do |sentence|
      expect(page).not_to have_content(sentence)
    end
  end

  scenario 'The search button text changes from \'Search\' to \'Refine search\' when the filters are applied' do
    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      fill_in 'subject', with: 'English'
      expect(find('.govuk-button').value).to eq('Search')
      click_on I18n.t('buttons.apply_filters')
    end

    within '.filters-form' do
      expect(find('.govuk-button').value).to eq(I18n.t('buttons.apply_filters_if_criteria'))
    end
  end

  context 'when the vacancy is part_time' do
    scenario 'Shows the weekly hours if there are weekly_hours' do
      vacancy = create(:vacancy, working_patterns: ['part_time'], weekly_hours: '5')
      Vacancy.__elasticsearch__.client.indices.flush
      visit job_path(vacancy)
      expect(page).to have_content(I18n.t('jobs.weekly_hours'))
      expect(page).to have_content(vacancy.weekly_hours)
    end

    scenario 'does not show the weekly hours if they are not set' do
      vacancy = create(:vacancy, working_patterns: ['part_time'], weekly_hours: nil)
      Vacancy.__elasticsearch__.client.indices.flush
      visit job_path(vacancy)
      expect(page).not_to have_content(I18n.t('jobs.weekly_hours'))
    end
  end

  context 'when the vacancy is full_time' do
    scenario 'Does not show the weekly hours even if weekly_hours is set' do
      vacancy = create(:vacancy, working_patterns: ['full_time'], weekly_hours: '5')
      Vacancy.__elasticsearch__.client.indices.flush
      visit job_path(vacancy)
      expect(page).not_to have_content(I18n.t('jobs.weekly_hours'))
    end
  end

  context 'when viewing vacancies created without expiry time' do
    scenario 'Vacancies do not display an expiry time' do
      vacancy = create(:vacancy, :with_no_expiry_time)
      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path(vacancy)

      verify_vacancy_list_page_details(VacancyPresenter.new(vacancy))
    end
  end

  context 'when the user is not on mobile' do
    scenario 'they should not see the \'refine your search\' link' do
      visit jobs_path
      expect(page).not_to have_content('Refine your search')
    end
  end

  context 'when the user is on mobile', js: true do
    scenario 'they should see the \'Show more filters\' link' do
      inspect_requests(inject_headers: { 'User-Agent' => USER_AGENTS['MOBILE_CHROME'] }) do
        visit jobs_path
      end
      expect(page).to have_content(I18n.t('jobs.filters.summary_collapsed'))
    end
  end
end
