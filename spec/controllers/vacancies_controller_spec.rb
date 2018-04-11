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
        create_list(:vacancy, 3)

        Vacancy.__elasticsearch__.refresh_index!

        get :index

        expect(response.status).to eq(Rack::Utils.status_code(:ok))
        expect(json[:vacancies].count).to eq(3)
      end
    end

    describe 'GET /vacancies/:id' do
      render_views
      it 'retrieves a specific vacancy' do
        vacancy = create(:vacancy)

        get :show, params: { id: vacancy.id }

        expect(response.status).to eq(Rack::Utils.status_code(:ok))
      end

      context 'json' do
        let(:vacancy) { create(:vacancy) }

        it 'maps fields to the JobSchema' do
          get :show, params: { id: vacancy.id }

          expect(json.to_h).to eq(vacancy_json_ld(vacancy))
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
                  "unitText": "YEAR"
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
                  "unitText": "YEAR"
                }
              }
            }
            expect(json.to_h).to include(salary)
          end
        end
      end
    end
  end
end
