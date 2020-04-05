require 'rails_helper'
RSpec.describe VacanciesPresenter do
  describe '#each' do
    it 'is delegated to the decorated collection' do
      create_list(:vacancy, 3)
      vacancies = Vacancy.all.page(1)
      searched = true
      decorated_vacancies = vacancies.map { |v| VacancyPresenter.new(v) }

      vacancies_presenter = VacanciesPresenter.new(vacancies, searched: searched)
      allow(vacancies_presenter).to receive(:decorated_collection).and_return(decorated_vacancies)

      expect(decorated_vacancies).to receive(:each)

      vacancies_presenter.each {}
    end
  end

  describe '#total_count_message' do
    it 'returns the correct number for a single vacancy', elasticsearch: true do
      create(:vacancy, job_title: 'School teacher')
      Vacancy.__elasticsearch__.client.indices.flush

      vacancies = Vacancy.search('Teacher').records
      searched = true
      vacancies_presenter = VacanciesPresenter.new(vacancies, searched: searched)
      expect(vacancies_presenter.total_count_message).to eq(I18n.t('jobs.job_count', count: 1))
    end

    it 'returns the correct number for multiple vacancies', elasticsearch: true do
      create(:vacancy, job_title: 'School teacher')
      create(:vacancy, job_title: 'Math teacher')
      create(:vacancy, job_title: 'English teacher')
      Vacancy.__elasticsearch__.client.indices.flush

      vacancies = Vacancy.search('Teacher').records
      searched = true
      vacancies_presenter = VacanciesPresenter.new(vacancies, searched: searched)
      expect(vacancies_presenter.total_count_message).to eq(I18n.t('jobs.job_count_plural', count: 3))
    end

    it 'returns the correct number for a single vacancy without a search', elasticsearch: true do
      create(:vacancy, job_title: 'School teacher')
      Vacancy.__elasticsearch__.client.indices.flush

      vacancies = Vacancy.search('Teacher').records
      searched = false
      vacancies_presenter = VacanciesPresenter.new(vacancies, searched: searched)
      expect(vacancies_presenter.total_count_message).to eq(I18n.t('jobs.job_count_without_search', count: 1))
    end

    it 'returns the correct number for multiple vacancies without a search', elasticsearch: true do
      create(:vacancy, job_title: 'School teacher')
      create(:vacancy, job_title: 'Math teacher')
      create(:vacancy, job_title: 'English teacher')
      Vacancy.__elasticsearch__.client.indices.flush

      vacancies = Vacancy.search('Teacher').records
      searched = false
      vacancies_presenter = VacanciesPresenter.new(vacancies, searched: searched)
      expect(vacancies_presenter.total_count_message).to eq(I18n.t('jobs.job_count_plural_without_search', count: 3))
    end
  end

  describe '#to_csv' do
    let!(:vacancy) { VacancyPresenter.new(create(:vacancy, job_title: 'School teacher')) }

    it 'returns the correct data', elasticsearch: true do
      Vacancy.__elasticsearch__.client.indices.flush

      vacancies = Vacancy.search('Teacher').records
      vacancies_presenter = VacanciesPresenter.new(vacancies, searched: false)
      vacancies_text = vacancies_presenter.to_csv
      vacancies_csv = CSV.parse(vacancies_text)

      expect(vacancies_csv[0]).to eq(%w[title description salary jobBenefits datePosted educationRequirements
                                        qualifications experienceRequirements employmentType
                                        jobLocation.addressLocality jobLocation.addressRegion
                                        jobLocation.streetAddress jobLocation.postalCode url
                                        hiringOrganization.type hiringOrganization.name
                                        hiringOrganization.identifier])

      expect(vacancies_csv[1]).to eq([vacancy.job_title,
                                      vacancy.job_summary,
                                      vacancy.salary,
                                      vacancy.benefits,
                                      vacancy.publish_on.to_time.iso8601,
                                      vacancy.education,
                                      vacancy.qualifications,
                                      vacancy.experience,
                                      vacancy.working_patterns_for_job_schema,
                                      vacancy.school.town,
                                      vacancy.school&.region&.name,
                                      vacancy.school.address,
                                      vacancy.school.postcode,
                                      Rails.application.routes.url_helpers.job_url(vacancy, protocol: 'https'),
                                      'School',
                                      vacancy.school.name,
                                      vacancy.school.urn])
    end
  end

  describe '#previous_api_url' do
    let(:vacancies_presenter) { VacanciesPresenter.new(vacancies, searched: false) }
    let(:vacancies) { double(:vacancies, map: [], prev_page: prev_page, total_count: 0) }

    context 'when there is a previous page' do
      let(:prev_page) { 4 }

      it 'returns the full url of the next page' do
        expect(vacancies_presenter.previous_api_url).to eq('https://localhost:3000/api/v1/jobs.json?page=4')
      end
    end

    context 'when there is no previous page' do
      let(:prev_page) { nil }

      it 'returns nil' do
        expect(vacancies_presenter.previous_api_url).to be_nil
      end
    end
  end

  describe '#next_api_url' do
    let(:vacancies_presenter) { VacanciesPresenter.new(vacancies, searched: false) }
    let(:vacancies) { double(:vacancies, map: [], next_page: next_page, total_count: 0) }

    context 'when there is a next page' do
      let(:next_page) { 2 }

      it 'returns the full url of the next page' do
        expect(vacancies_presenter.next_api_url).to eq('https://localhost:3000/api/v1/jobs.json?page=2')
      end
    end

    context 'when there is no next page' do
      let(:next_page) { nil }

      it 'returns nil' do
        expect(vacancies_presenter.next_api_url).to be_nil
      end
    end
  end
end
