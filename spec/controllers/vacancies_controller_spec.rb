require 'rails_helper'

RSpec.describe VacanciesController, type: :controller do
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

  describe 'GET /vacancies/:id', elasticsearch: true do
    render_views
    it 'retrieves a specific vacancy' do
      vacancy = create(:vacancy)

      Vacancy.__elasticsearch__.refresh_index!

      get :show, params: { id: vacancy.id }

      expect(response.status).to eq(Rack::Utils.status_code(:ok))
      expect(json.to_h).to eq(vacancy_json_ld(vacancy))
    end
  end
end
