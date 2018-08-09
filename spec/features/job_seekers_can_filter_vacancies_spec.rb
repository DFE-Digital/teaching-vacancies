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
    lower_paid_vacancy = create(:vacancy, :published, minimum_salary: 28000)
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

  scenario 'Filterable by maximum salary', elasticsearch: true do
    lower_paid_vacancy = create(:vacancy, :published, maximum_salary: 30000)
    higher_paid_vacancy = create(:vacancy, :published, maximum_salary: 45000)

    Vacancy.__elasticsearch__.client.indices.flush
    visit jobs_path

    within '.filters-form' do
      select '£40,000', from: 'maximum_salary'
      page.find('.button[type=submit]').click
    end

    expect(page).to have_content(lower_paid_vacancy.job_title)
    expect(page).not_to have_content(higher_paid_vacancy.job_title)
  end
end
