require 'rails_helper'

RSpec.describe VacanciesController, type: :controller do
  context 'JSON api' do
    let(:json) { JSON.parse(response.body, symbolize_names: true) }

    before(:each) do
      request.accept = 'application/json'
    end

    describe 'GET /vacancies', elasticsearch: true do
      render_views

      it 'retrieves all available vacancies' do
        vacancies = create_list(:vacancy, 3)

        Vacancy.__elasticsearch__.refresh_index!

        get :index

        expect(response.status).to eq(Rack::Utils.status_code(:ok))
        expect(json[:vacancies].count).to eq(3)
        vacancies.each do |v|
          expect(json[:vacancies]).to include(vacancy_json_ld(VacancyPresenter.new(v)))
        end
      end
    end

    describe 'GET /vacancies/:id' do
      render_views
      let(:vacancy) { create(:vacancy) }

      it 'returns status code :ok' do
        get :show, params: { id: vacancy.id }

        expect(response.status).to eq(Rack::Utils.status_code(:ok))
      end

      context 'format' do
        it 'maps vacancy to the JobPosting schema' do
          get :show, params: { id: vacancy.id }

          expect(json.to_h).to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)))
        end

        context '#salary' do
          it 'when both minimum and maximum salary are set' do
            get :show, params: { id: vacancy.id }

            salary = {
              'baseSalary': {
                '@type': 'MonetaryAmount',
                'currency': 'GBP',
                value: {
                  '@type': 'QuantitativeValue',
                  'minValue': vacancy.minimum_salary,
                  'maxValue': vacancy.maximum_salary,
                  'unitText': 'YEAR'
                }
              }
            }
            expect(json.to_h).to include(salary)
          end

          it 'when no maximum salary is set' do
            vacancy = create(:vacancy, maximum_salary: nil)
            get :show, params: { id: vacancy.id }

            salary = {
              'baseSalary': {
                '@type': 'MonetaryAmount',
                'currency': 'GBP',
                value: {
                  '@type': 'QuantitativeValue',
                  'value': vacancy.minimum_salary,
                  'unitText': 'YEAR'
                }
              }
            }
            expect(json.to_h).to include(salary)
          end
        end

        context '#employment_type' do
          it 'FULL_TIME' do
            get :show, params: { id: vacancy.id }

            employment_type = { 'employmentType': 'FULL_TIME' }
            expect(json.to_h).to include(employment_type)
          end

          it 'PART_TIME' do
            vacancy = create(:vacancy, working_pattern: :part_time)

            get :show, params: { id: vacancy.id }

            employment_type = { 'employmentType': 'PART_TIME' }
            expect(json.to_h).to include(employment_type)
          end
        end

        context '#hiringOrganization' do
          it 'sets the school\'s details' do
            get :show, params: { id: vacancy.id }

            hiring_organization = {
              'hiringOrganization': {
                '@type': 'School',
                'name': vacancy.school.name,
                'identifier': vacancy.school.urn,
              }
            }
            expect(json.to_h).to include(hiring_organization)
          end
        end
      end
    end
  end
end
