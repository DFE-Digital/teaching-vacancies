require 'rails_helper'

RSpec.describe Api::VacanciesController, type: :controller do
  let(:json) { JSON.parse(response.body, symbolize_names: true) }

  before(:each, :json) do
    request.accept = 'application/json'
  end

  describe 'GET /api/v1/jobs.html' do
    it 'returns status :not_found as only JSON format is allowed' do
      get :index, params: { api_version: 1 }, format: :html

      expect(response.status).to eq(Rack::Utils.status_code(:not_found))
    end
  end

  describe 'GET /api/v1/jobs.json', elasticsearch: true, json: true do
    render_views

    context 'sets headers' do
      before(:each) { get :index, params: { api_version: 1 } }

      it_behaves_like 'X-Robots-Tag'
      it_behaves_like 'Content-Type JSON'
    end

    it 'returns status :not_found if the request format is not JSON' do
      get :index, params: { api_version: 1 }, format: :html

      expect(response.status).to eq(Rack::Utils.status_code(:not_found))
    end

    it 'returns the API\'s openapi version' do
      get :index, params: { api_version: 1 }

      expect(json[:openapi]).to eq('3.0.0')
    end

    it 'returns the API\'s info' do
      get :index, params: { api_version: 1 }

      info_object = json[:info]
      expect(info_object[:title]).to eq("GOV UK - #{I18n.t('app.title')}")
      expect(info_object[:description]).to eq(I18n.t('app.description'))
      expect(info_object[:termsOfService])
        .to eq(terms_and_conditions_url(protocol: 'https', anchor: 'api'))
      expect(info_object[:contact][:email]).to eq(I18n.t('help.email'))
    end

    it 'returns a links object' do
      get :index, params: { api_version: 1 }

      expect(json[:links].keys).to include(:self, :first, :last, :prev, :next)
    end

    it 'retrieves all available vacancies' do
      skip_vacancy_publish_on_validation
      published_vacancy = create(:vacancy)
      expired_vacancy = create(:vacancy, :expired)

      vacancies = [published_vacancy, expired_vacancy]

      Vacancy.__elasticsearch__.refresh_index!

      get :index, params: { api_version: 1 }

      expect(response.status).to eq(Rack::Utils.status_code(:ok))
      expect(json[:data].count).to eq(2)
      vacancies.each do |v|
        expect(json[:data]).to include(vacancy_json_ld(VacancyPresenter.new(v)))
      end
    end

    context 'when there are more vacancies than the per-page limit' do
      before do
        stub_const('Api::VacanciesController::MAX_API_RESULTS_PER_PAGE', per_page)
        create_list(:vacancy, 16)
        Vacancy.__elasticsearch__.refresh_index!

        get :index, params: { api_version: 1, page: 2 }
      end

      let(:per_page) { 5 }
      let(:links_object) { json[:links] }

      it 'paginates the result' do
        expect(json[:data].count).to eq(per_page)
      end

      it 'includes the correct pagination links' do
        expect(links_object).to include(
          self: 'https://localhost:3000/api/v1/jobs.json?page=2',
          first: 'https://localhost:3000/api/v1/jobs.json?page=1',
          last: 'https://localhost:3000/api/v1/jobs.json?page=4',
          next: 'https://localhost:3000/api/v1/jobs.json?page=3',
          prev: 'https://localhost:3000/api/v1/jobs.json?page=1'
        )
      end

      it 'includes the total pages' do
        expect(json[:meta]).to include(totalPages: 4)
      end
    end

    it 'does not retrieve incomplete or deleted vacancies' do
      create(:vacancy, :draft)
      create(:vacancy, :trashed)
      create(:vacancy, :future_publish)

      Vacancy.__elasticsearch__.refresh_index!

      get :index, params: { api_version: 1 }

      expect(response.status).to eq(Rack::Utils.status_code(:ok))
      expect(json[:data].count).to eq(0)
    end
  end

  describe 'GET /api/v1/jobs/:id.json', json: true do
    render_views
    let(:vacancy) { create(:vacancy) }

    it 'returns status :not_found if the request format is not JSON' do
      get :show, params: { id: vacancy.slug, api_version: 1 }, format: :html

      expect(response.status).to eq(Rack::Utils.status_code(:not_found))
    end

    context 'sets headers' do
      before(:each) { get :show, params: { id: vacancy.slug, api_version: 1 } }

      it_behaves_like 'X-Robots-Tag'
      it_behaves_like 'Content-Type JSON'
    end

    it 'returns status code :ok' do
      get :show, params: { id: vacancy.slug, api_version: 1 }

      expect(response.status).to eq(Rack::Utils.status_code(:ok))
    end

    it 'never redirects to latest url' do
      vacancy = create(:vacancy, :published)
      old_slug = vacancy.slug
      vacancy.job_title = 'A new job title'
      vacancy.refresh_slug
      vacancy.save

      get :show, params: { id: old_slug, api_version: 1 }
      expect(response.status).to eq(Rack::Utils.status_code(:ok))
    end

    context 'format' do
      it 'maps vacancy to the JobPosting schema' do
        get :show, params: { id: vacancy.id, api_version: 1 }

        expect(json.to_h).to eq(vacancy_json_ld(VacancyPresenter.new(vacancy)))
      end

      context '#employment_type' do
        it 'maps full_time working pattern to FULL_TIME' do
          vacancy = create(:vacancy, working_patterns: ['full_time'])

          get :show, params: { id: vacancy.id, api_version: 1 }

          expect(json.to_h).to include('employmentType': 'FULL_TIME')
        end

        it 'maps part_time working pattern to PART_TIME' do
          vacancy = create(:vacancy, working_patterns: ['part_time'])

          get :show, params: { id: vacancy.id, api_version: 1 }

          expect(json.to_h).to include('employmentType': 'PART_TIME')
        end

        it 'maps job_share working pattern to JOB_SHARE' do
          vacancy = create(:vacancy, working_patterns: ['job_share'])

          get :show, params: { id: vacancy.id, api_version: 1 }

          expect(json.to_h).to include('employmentType': 'JOB_SHARE')
        end

        it 'maps compressed_hours working pattern to COMPRESSED_HOURS' do
          vacancy = create(:vacancy, working_patterns: ['compressed_hours'])

          get :show, params: { id: vacancy.id, api_version: 1 }

          expect(json.to_h).to include('employmentType': 'COMPRESSED_HOURS')
        end

        it 'maps staggered_hours working pattern to STAGGERED_HOURS' do
          vacancy = create(:vacancy, working_patterns: ['staggered_hours'])

          get :show, params: { id: vacancy.id, api_version: 1 }

          expect(json.to_h).to include('employmentType': 'STAGGERED_HOURS')
        end

        it 'maps multiple values to an array' do
          vacancy = create(:vacancy, working_patterns: ['part_time', 'job_share', 'staggered_hours'])

          get :show, params: { id: vacancy.id, api_version: 1 }

          expect(json.to_h).to include('employmentType': 'PART_TIME, JOB_SHARE, STAGGERED_HOURS')
        end
      end

      context '#hiringOrganization' do
        it 'sets the school\'s details' do
          get :show, params: { id: vacancy.id, api_version: 1 }

          hiring_organization = {
            'hiringOrganization': {
              '@type': 'School',
              'name': vacancy.school.name,
              'identifier': vacancy.school.urn,
              'description': "<p>#{vacancy.about_school}</p>"
            }
          }
          expect(json.to_h).to include(hiring_organization)
        end
      end
    end
  end
end
