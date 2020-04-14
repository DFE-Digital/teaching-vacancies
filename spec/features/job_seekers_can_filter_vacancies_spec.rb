require 'rails_helper'

RSpec.feature 'Filtering vacancies' do
  context 'when filtering by location', elasticsearch: true do
    scenario 'search radius defaults to 20' do
      visit jobs_path

      within '.filters-form' do
        expect(page).to have_select('radius', selected: 'Within 20 miles')
      end
    end

    scenario 'search results can be filtered by the selected location and radius' do
      allow(LocationCategory).to receive(:include?).with('enfield').and_return(false)
      expect(Geocoder).to receive(:coordinates).with('enfield')
                                               .and_return([51.6622925, -0.1180655])
      enfield_vacancy = create(:vacancy, :published,
                               school: build(:school, name: 'St James School',
                                                      town: 'Enfield',
                                                      geolocation: '(51.6580645, -0.0448643)'))
      penzance_vacancy = create(:vacancy, :published, school: build(:school, name: 'St James School',
                                                                             town: 'Penzance'))

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        fill_in 'location', with: 'enfield'
        select 'Within 25 miles'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content(enfield_vacancy.job_title)
      expect(page).not_to have_content(penzance_vacancy.job_title)
    end
  end

  context 'when filtering by a Location Category' do
    let!(:london_region) { Region.find_or_create_by(name: 'London') }
    let!(:east_sussex) do
      create(:vacancy, :published,
        school: build(:school, county: 'East Sussex'))
    end

    let!(:west_sussex) do
      create(:vacancy, :published,
        school: build(:school, county: 'West Sussex'))
    end

    before do
      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        fill_in 'location', with: 'west sussex'
        page.find('.govuk-button[type=submit]').click
      end
    end

    scenario 'search results returned have been filtered by the location category' do
      expect(page).to have_content(west_sussex.job_title)
      expect(page).not_to have_content(east_sussex.job_title)
    end

    scenario 'radius filter is disabled' do
      expect(page).to have_field('radius', disabled: true)
    end

    scenario 'radius filter is re-enabled when the location field is clicked', js: true do
      expect(page).to have_field('radius', disabled: true)
      page.find('#location').click

      expect(page).to have_field('radius', disabled: false)
    end
  end

  context 'with jobs with various job titles and subjects', elasticsearch: true do
    let!(:headmaster_vacancy) { create(:vacancy, :published, job_title: 'Headmaster') }
    let!(:english_title_vacancy) { create(:vacancy, :published, job_title: 'English Language') }
    let!(:english_subject_vacancy) do
      create(:vacancy, job_title: 'Foo Tutor', subject: create(:subject, name: 'English'))
    end
    let!(:arts_vacancy) do
      create(:vacancy, job_title: 'Arts Tutor', subject: create(:subject, name: 'Arts'),
                       first_supporting_subject: create(:subject, name: 'English'))
    end
    let!(:maths_vacancy) do
      create(:vacancy, job_title: 'Maths Subject Leader', subject: create(:subject, name: 'Maths'))
    end

    before(:each) { Vacancy.__elasticsearch__.client.indices.flush }

    scenario 'is filterable by subject' do
      visit jobs_path

      within '.filters-form' do
        fill_in 'keyword', with: 'English'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).not_to have_content(headmaster_vacancy.job_title)
      expect(page).not_to have_content(maths_vacancy.job_title)
      expect(page).to have_content(english_title_vacancy.job_title)
      expect(page).to have_content(arts_vacancy.job_title)
      expect(page).to have_content(english_subject_vacancy.job_title)
    end

    scenario 'is filterable by job title' do
      visit jobs_path

      within '.filters-form' do
        fill_in 'keyword', with: 'Tutor'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).not_to have_content(headmaster_vacancy.job_title)
      expect(page).not_to have_content(maths_vacancy.job_title)
      expect(page).not_to have_content(english_title_vacancy.job_title)
      expect(page).to have_content(arts_vacancy.job_title)
      expect(page).to have_content(english_subject_vacancy.job_title)
    end
  end

  context 'when searching triggers a job to write a search_event to the audit table', elasticsearch: true do
    scenario 'correctly logs the number of non-paginated results' do
      create_list(:vacancy, 3, :published, job_title: 'Physics', newly_qualified_teacher: true)
      create(:vacancy, :published, newly_qualified_teacher: false)
      timestamp = Time.zone.now.iso8601

      Vacancy.__elasticsearch__.client.indices.flush

      data = {
        total_count: 3,
        location: '',
        radius: '20',
        keyword: 'Physics',
        working_patterns: nil,
        phases: nil,
        newly_qualified_teacher: nil,
        subject: nil,
        job_title: nil
      }

      expect(AuditSearchEventJob).to receive(:perform_later)
        .with(data)

      visit jobs_path

      Timecop.freeze(timestamp) do
        within '.filters-form' do
          fill_in 'keyword', with: 'Physics'
          page.find('.govuk-button[type=submit]').click
        end
      end
    end

    scenario 'correctly logs the total results when pagination is used', elasticsearch: true do
      create_list(:vacancy, 12, :published, job_title: 'Math', newly_qualified_teacher: true)
      timestamp = Time.zone.now.iso8601

      Vacancy.__elasticsearch__.client.indices.flush

      data = {
        total_count: 12,
        location: '',
        radius: '20',
        keyword: 'Math',
        working_patterns: nil,
        phases: nil,
        newly_qualified_teacher: nil,
        subject: nil,
        job_title: nil
      }

      expect(AuditSearchEventJob).to receive(:perform_later)
        .with(data)

      visit jobs_path

      Timecop.freeze(timestamp) do
        within '.filters-form' do
          fill_in 'keyword', with: 'Math'
          page.find('.govuk-button[type=submit]').click
        end
      end
    end
  end

  context 'when resetting search filters', elasticsearch: true do
    it 'hiring staff can reset search after filtering' do
      create(:vacancy, :published, job_title: 'Physics Teacher')

      Vacancy.__elasticsearch__.client.indices.flush
      visit jobs_path

      within '.filters-form' do
        fill_in 'keyword', with: 'Physics'
        page.find('.govuk-button[type=submit]').click
      end

      expect(page).to have_content(I18n.t('jobs.filters.clear_filters'))

      select I18n.t('jobs.sort_by_earliest_closing_date')
      click_button I18n.t('jobs.sort_submit')

      expect(page).to have_content(I18n.t('jobs.filters.clear_filters'))
    end

    it 'hiring staff can reset search after adding any filter params to the url' do
      create(:vacancy, :published, job_title: 'Physics Teacher')
      Vacancy.__elasticsearch__.client.indices.flush

      visit jobs_path(subject: 'Other')

      expect(page).to have_content(I18n.t('jobs.filters.clear_filters'))
    end
  end
end
