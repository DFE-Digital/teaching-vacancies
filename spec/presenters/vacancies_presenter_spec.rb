require 'rails_helper'
RSpec.describe VacanciesPresenter do
  describe '#each' do
    it 'is delegated to the decorated collection' do
      vacancies = create_list(:vacancy, 3)
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
    it 'returns the correct number for multiple vacancies', elasticsearch: true do
      vacancy = VacancyPresenter.new(create(:vacancy, job_title: 'School teacher'))
      Vacancy.__elasticsearch__.client.indices.flush

      vacancies = Vacancy.search('Teacher').records
      vacancies_presenter = VacanciesPresenter.new(vacancies, searched: false)
      vacancies_text = vacancies_presenter.to_csv
      vacancies_csv = CSV.parse(vacancies_text)

      expect(vacancies_csv[0]).to eq(%w[title description jobBenefits datePosted educationRequirements
                                        qualifications experienceRequirements employmentType
                                        jobLocation.addressLocality jobLocation.addressRegion
                                        jobLocation.streetAddress jobLocation.postalCode url
                                        baseSalary.currency baseSalary.minValue baseSalary.maxValue
                                        baseSalary.unitText hiringOrganization.type hiringOrganization.name
                                        hiringOrganization.identifier])

      expect(vacancies_csv[1]).to eq([vacancy.job_title, vacancy.job_description,
                                      vacancy.benefits, vacancy.publish_on.to_time.iso8601, vacancy.education,
                                      vacancy.qualifications, vacancy.experience,
                                      vacancy.working_pattern_for_job_schema, vacancy.school.town,
                                      vacancy.school&.region&.name, vacancy.school.address,
                                      vacancy.school.postcode,
                                      Rails.application.routes.url_helpers.job_url(vacancy, protocol: 'https'),
                                      'GBP', vacancy.minimum_salary, vacancy.maximum_salary, 'YEAR',
                                      'School', vacancy.school.name, vacancy.school.urn])
    end
  end
end
