require 'rails_helper'

RSpec.feature 'Filtering vacancies' do
  scenario 'Filterable by keyword', elasticsearch: true do
    headmaster = create(:vacancy, :published, job_title: 'Headmaster')
    languages_teacher = create(:vacancy, :published, job_title: 'Languages Teacher')

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      fill_in 'keyword', with: 'Headmaster'
      page.find('.button[type=submit]').click
    end

    expect(page).to have_content(headmaster.job_title)
    expect(page).not_to have_content(languages_teacher.job_title)
  end

  scenario 'Filterable by location', elasticsearch: true do
    expect(Geocoder).to receive(:coordinates).with('enfield', params: { region: 'uk' })
                                             .and_return([51.6622925, -0.1180655])
    enfield_vacancy = create(:vacancy, :published,
                             school: build(:school, name: 'St James School',
                                                    town: 'Enfield',
                                                    geolocation: '(51.6580645, -0.0448643)'))
    penzance_vacancy = create(:vacancy, :published, school: build(:school, name: 'St James School', town: 'Penzance'))

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      fill_in 'location', with: 'enfield'
      select 'Within 25 miles'
      page.find('.button[type=submit]').click
    end

    expect(page).to have_content(enfield_vacancy.job_title)
    expect(page).not_to have_content(penzance_vacancy.job_title)
  end

  scenario 'Filterable by working pattern', elasticsearch: true do
    part_time_vacancy = create(:vacancy, :published, working_pattern: :part_time)
    full_time_vacancy = create(:vacancy, :published, working_pattern: :full_time)

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      select 'Part time', from: 'working_pattern'
      page.find('.button[type=submit]').click
    end

    expect(page).to have_content(part_time_vacancy.job_title)
    expect(page).not_to have_content(full_time_vacancy.job_title)
  end

  scenario 'Filterable by education phase', elasticsearch: true do
    primary_vacancy = create(:vacancy, :published, school: build(:school, :primary))
    secondary_vacancy = create(:vacancy, :published, school: build(:school, :secondary))

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      select 'Primary', from: 'phase'
      page.find('.button[type=submit]').click
    end

    expect(page).to have_content(primary_vacancy.job_title)
    expect(page).not_to have_content(secondary_vacancy.job_title)
  end

  scenario 'Filterable by minimum salary', elasticsearch: true do
    lower_paid_vacancy = create(:vacancy, :published, minimum_salary: 18000, maximum_salary: 20000)
    higher_paid_vacancy = create(:vacancy, :published, minimum_salary: 42000, maximum_salary: 45000)

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      select '£30,000', from: 'minimum_salary'
      page.find('.button[type=submit]').click
    end

    expect(page).to have_content(higher_paid_vacancy.job_title)
    expect(page).not_to have_content(lower_paid_vacancy.job_title)
  end

  context 'Filterable by maximum salary', elasticsearch: true do
    scenario 'when a job\'s maximum salary is set', elasticsearch: true do
      lower_paid_vacancy = create(:vacancy, :published, minimum_salary: 18000, maximum_salary: 20000)
      higher_paid_vacancy = create(:vacancy, :published, minimum_salary: 42000, maximum_salary: 45000)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        select '£40,000', from: 'maximum_salary'
        page.find('.button[type=submit]').click
      end

      expect(page).to have_content(lower_paid_vacancy.job_title)
      expect(page).not_to have_content(higher_paid_vacancy.job_title)
    end

    scenario 'when a job\'s maximum salary is not  set', elasticsearch: true do
      no_maximum = create(:vacancy, :published, minimum_salary: 18000, maximum_salary: nil)
      higher_paid_vacancy = create(:vacancy, :published, minimum_salary: 42000, maximum_salary: 45000)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        select '£40,000', from: 'maximum_salary'
        page.find('.button[type=submit]').click
      end

      expect(page).to have_content(no_maximum.job_title)
      expect(page).not_to have_content(higher_paid_vacancy.job_title)
    end
  end

  context 'Filterable by both minimum and maximum salary', elasticsearch: true do
    scenario 'when a job\'s salary is within the specified salary range', elasticsearch: true do
      no_match = create(:vacancy, :published, minimum_salary: 30000, maximum_salary: 41000)
      other_higher_paid_vacancy = create(:vacancy, :published, minimum_salary: 42000, maximum_salary: 125000)
      higher_paid_vacancy = create(:vacancy, :published, minimum_salary: 40000, maximum_salary: 41000)
      other_paid_vacancy = create(:vacancy, :published, minimum_salary: 40000, maximum_salary: 50000)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        select '£40,000', from: 'minimum_salary'
        select '£50,000', from: 'maximum_salary'
        page.find('.button[type=submit]').click
      end

      expect(page).not_to have_content(no_match.job_title)
      expect(page).not_to have_content(other_higher_paid_vacancy.job_title)
      expect(page).to have_content(higher_paid_vacancy.job_title)
      expect(page).to have_content(other_paid_vacancy.job_title)
    end

    scenario 'when a job\'s salary is not within the specified salary range', elasticsearch: true do
      no_match = create(:vacancy, :published, minimum_salary: 30000, maximum_salary: 41000)
      other_paid_vacancy = create(:vacancy, :published, minimum_salary: 40000, maximum_salary: 50000)
      create(:vacancy, :published, minimum_salary: 40000, maximum_salary: 60000)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        select '£40,000', from: 'minimum_salary'
        select '£50,000', from: 'maximum_salary'
        page.find('.button[type=submit]').click
      end

      expect(page).to have_content(I18n.t('jobs.job_count', count: 1))
      expect(page).not_to have_content(no_match.job_title)
      expect(page).to have_content(other_paid_vacancy.job_title)
    end

    scenario 'when a job\'s maximum salary is not set', elasticsearch: true do
      lower_paid_vacancy = create(:vacancy, :published, minimum_salary: 20000, maximum_salary: nil)
      higher_paid_vacancy = create(:vacancy, :published, minimum_salary: 39000, maximum_salary: 45000)
      create(:vacancy, :published, minimum_salary: 45000, maximum_salary: 65000)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        select '£20,000', from: 'minimum_salary'
        select '£50,000', from: 'maximum_salary'
        page.find('.button[type=submit]').click
      end

      expect(page).to have_content(I18n.t('jobs.job_count_plural', count: 2))
      expect(page).to have_content(higher_paid_vacancy.job_title)
      expect(page).to have_content(lower_paid_vacancy.job_title)
    end

    scenario 'a user clears their search', elasticsearch: true do
      create(:vacancy, :published, job_title: 'Physics Teacher')

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      expect(page).not_to have_content(I18n.t('jobs.filters.clear_filters'))

      within '.filters-form' do
        fill_in 'keyword', with: 'Physics'
        page.find('.button[type=submit]').click
      end

      expect(page).to have_content(I18n.t('jobs.filters.clear_filters'))

      click_on I18n.t('jobs.filters.clear_filters')
      expect(current_path).to eq root_path
    end
  end

  context 'Filterable by newly qualified teacher', elasticsearch: true do
    scenario 'Suitable for NQTs' do
      nqt_suitable_vacancy = create(:vacancy, :published, newly_qualified_teacher: true)
      not_nqt_suitable_vacancy = create(:vacancy, :published, newly_qualified_teacher: false)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        check 'newly_qualified_teacher'
        page.find('.button[type=submit]').click
      end

      expect(page).to have_content(nqt_suitable_vacancy.job_title)
      expect(page).not_to have_content(not_nqt_suitable_vacancy.job_title)
      expect(page).to have_field('newly_qualified_teacher', checked: true)
    end

    scenario 'Display all available jobs when NQT suitable is unchecked' do
      nqt_suitable_vacancy = create(:vacancy, :published, newly_qualified_teacher: true)
      not_nqt_suitable_vacancy = create(:vacancy, :published, newly_qualified_teacher: false)

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        check 'newly_qualified_teacher'
        uncheck 'newly_qualified_teacher'
        page.find('.button[type=submit]').click
      end

      expect(page).to have_content(not_nqt_suitable_vacancy.job_title)
      expect(page).to have_content(nqt_suitable_vacancy.job_title)
      expect(page).to have_field('newly_qualified_teacher', checked: false)
    end
  end
end
