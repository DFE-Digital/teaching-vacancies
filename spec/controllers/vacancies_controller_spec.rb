require 'rails_helper'

RSpec.describe VacanciesController, type: :controller do
  describe 'sets headers' do
    it 'robots are asked to index but not to follow' do
      get :index
      expect(response.headers['X-Robots-Tag']).to eq('noarchive')
    end
  end

  describe '#index' do
    context 'when parameters include syntax' do
      it 'passes only safe values to VacancyFilters' do
        received_values = {
          keyword: "<body onload=alert('test1')>Text</script>",
          location: "<img src='http://url.to.file.which/not.exist' onerror=alert(document.cookie);>",
          minimum_salary: '<xml>Foo</xml',
          maximum_salary: '<css>Foo</css>',
          phase: '<script>Foo</script>',
          working_pattern: '<script>Foo</script>',
        }

        expected_safe_values = {
          'keyword' => 'Text',
          'location' => '',
          'minimum_salary' => 'Foo',
          'maximum_salary' => 'Foo',
          'phase' => 'Foo',
          'working_pattern' => 'Foo',
        }

        expect(VacancyFilters).to receive(:new)
          .with(expected_safe_values)
          .and_call_original

        get :index, params: received_values
      end

      it 'passes sanitised params to VacancySort' do
        received_values = {
          sort_column: "<body onload=alert('test1')>Text</script>",
          sort_order: '<xml>Foo</xml',
        }

        expected_safe_values = {
          column: 'Text',
          order: 'Foo',
        }

        expect_any_instance_of(VacancySort).to receive(:update)
          .with(expected_safe_values)
          .and_call_original

        get :index, params: received_values
      end
    end

    it 'invokes pagination correctly to ensure sort order persists' do
      create(:vacancy)

      # This assertion ensures the ordering of search and pagination stays correct
      # in future as the gem allows you to call `page` on 2 similar objects.
      #
      # Correct:
      # - Vacancy.search.page.records
      # - Vacancy.search.page => Elasticsearch::Model::Response::Records
      # Incorrect:
      # - Vacancy.search.records.page
      # - Vacancy.search.records => Elasticsearch::Model::Response::Response

      elasticsearch_response = instance_double(Elasticsearch::Model::Response::Response)
      allow(Vacancy).to receive(:public_search).and_return(elasticsearch_response)
      expect(elasticsearch_response).to receive(:page).and_return(elasticsearch_response)
      expect(elasticsearch_response).to receive(:records).and_return([])

      get :index
    end
  end

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
        get :show, params: { id: vacancy.slug }

        expect(response.status).to eq(Rack::Utils.status_code(:ok))
      end

      it 'never redirects to latest url' do
        vacancy = create(:vacancy, :published)
        old_slug = vacancy.slug
        vacancy.job_title = 'A new job title'
        vacancy.refresh_slug
        vacancy.save

        get :show, params: { id: old_slug }
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
