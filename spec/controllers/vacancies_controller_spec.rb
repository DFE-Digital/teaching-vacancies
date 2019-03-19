require 'rails_helper'

RSpec.describe VacanciesController, type: :controller do
  describe 'sets headers' do
    it 'robots are asked to index but not to follow' do
      get :index
      expect(response.headers['X-Robots-Tag']).to eq('noarchive')
    end
  end

  describe '#index' do
    let(:subject) { get :index, params: params }
    context 'when parameters include syntax' do
      context 'search params' do
        let(:params) do
          {
            keyword: "<body onload=alert('test1')>Text</body>",
            location: "<img src='http://url.to.file.which/not.exist' onerror=alert(document.cookie);>",
            minimum_salary: '<xml>Foo</xml',
            maximum_salary: '<style>Foo</style>',
            phase: '<iframe>Foo</iframe>',
            working_pattern: '<script>Foo</script>',
          }
        end

        it 'passes only safe values to VacancyFilters' do
          expected_safe_values = {
            'keyword' => 'Text',
            'location' => '',
            'minimum_salary' => 'Foo',
            'maximum_salary' => '',
            'phase' => '',
            'working_pattern' => '',
          }

          expect(VacancyFilters).to receive(:new)
            .with(expected_safe_values)
            .and_call_original

          subject
        end
      end

      context 'sort params' do
        let(:params) do
          {
            sort_column: "<body onload=alert('test1')>Text</script>",
            sort_order: '<xml>Foo</xml',
          }
        end
        it 'passes sanitised params to VacancySort' do
          expected_safe_values = {
            column: 'Text',
            order: 'Foo',
          }

          expect_any_instance_of(VacancySort).to receive(:update)
            .with(expected_safe_values)
            .and_call_original

          subject
        end
      end

      context 'when parameters are given' do
        let(:params) { { keyword: 'English' } }
        it 'calls ElasticSearch' do
          expect(Vacancy).to receive(:__elasticsearch__).and_call_original

          subject
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
          records = instance_double(Elasticsearch::Model::Response::Records)
          expect(Vacancy).to receive(:public_search).ordered.and_return(elasticsearch_response)
          expect(elasticsearch_response).to receive(:page).ordered.and_return(elasticsearch_response)
          expect(elasticsearch_response).to receive(:records).ordered.and_return(records)
          expect(records).to receive(:total_count) { 0 }
          expect(records).to receive(:map)

          subject
        end
      end

      context 'when no parameters are given' do
        let(:params) { {} }
        it 'does not call ElasticSearch' do
          expect(Vacancy).to_not receive(:__elasticsearch__)
          subject
        end
      end
    end

    context 'feature flagging' do
      render_views

      context 'when the email alerts feature flag is set to true' do
        before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }

        it 'shows the subscribe link' do
          get :index, params: { keyword: 'English' }
          expect(response.body).to match(I18n.t('subscriptions.button'))
        end
      end

      context 'when the email alerts feature flag is set to false' do
        before { allow(EmailAlertsFeature).to receive(:enabled?) { false } }

        it 'does not show the subscribe link' do
          get :index, params: { keyword: 'English' }
          expect(response.body).to_not match(I18n.t('subscriptions.button'))
        end
      end
    end
  end
end
