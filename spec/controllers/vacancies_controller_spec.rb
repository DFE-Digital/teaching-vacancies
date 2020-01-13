require 'rails_helper'

RSpec.describe VacanciesController, type: :controller do
  describe 'sets headers' do
    it 'robots are asked to index but not to follow' do
      get :index
      expect(response.headers['X-Robots-Tag']).to eq('noarchive')
    end
  end

  describe '#index' do
    subject { get :index, params: params }

    context 'when parameters include syntax' do
      context 'search params' do
        let(:params) do
          {
            subject: "<body onload=alert('test1')>Text</body>",
            location: "<img src='http://url.to.file.which/not.exist' onerror=alert(document.cookie);>",
            minimum_salary: '<xml>Foo</xml',
            phases: ['<iframe>Foo</iframe>', 'Bar'],
            working_patterns: ['<script>Foo</script>'],
          }
        end

        it 'passes only safe values to VacancyFilters' do
          expected_safe_values = {
            'subject' => 'Text',
            'location' => '',
            'minimum_salary' => 'Foo',
            'phases' => '["", "Bar"]',
            'working_patterns' => '[""]'
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

      context 'search auditor' do
        let(:params) do
          {
            job_title: 'Should have three match'
          }
        end

        it 'should call the search auditor', elasticsearch: true do
          3.times { create(:vacancy, job_title: 'Should have three match') }
          Vacancy.__elasticsearch__.client.indices.flush
          expect(AuditSearchEventJob).to receive(:perform_later).with(
            hash_including(
              total_count: 3,
              job_title: 'Should have three match'
            )
          )

          subject
        end

        it 'should not call the search auditor if its a smoke test' do
          cookies[:smoke_test] = 1
          expect(AuditSearchEventJob).to_not receive(:perform_later)

          subject
        end

        it 'should not call the search auditor if no search parameters are given' do
          expect(AuditSearchEventJob).to_not receive(:perform_later)

          get :index
        end
      end
    end

    context 'jobs_sort option' do
      let(:search_params) do
        {
          subject: 'Business Studies',
          location: 'Torquay',
          minimum_salary: '1',
        }
      end

      let(:search_path) { jobs_path(params: search_params.merge(expanded_search_params), anchor: 'jobs_sort') }

      context 'when parameters include the sort_by_most_recent jobs_sort option' do
        let(:params) { search_params.merge(jobs_sort: 'sort_by_most_recent') }
        let(:expanded_search_params) { { sort_column: 'publish_on', sort_order: 'desc' } }

        it 'redirects to the full search path' do
          expect(subject).to redirect_to(search_path)
        end
      end

      context 'when parameters include the sort_by_most_ancient jobs_sort option' do
        let(:params) { search_params.merge(jobs_sort: 'sort_by_most_ancient') }
        let(:expanded_search_params) { { sort_column: 'publish_on', sort_order: 'asc' } }

        it 'redirects to the full search path' do
          expect(subject).to redirect_to(search_path)
        end
      end

      context 'when parameters include the sort_by_earliest_closing_date jobs_sort option' do
        let(:params) { search_params.merge(jobs_sort: 'sort_by_earliest_closing_date') }
        let(:expanded_search_params) { { sort_column: 'expires_on', sort_order: 'asc' } }

        it 'redirects to the full search path' do
          expect(subject).to redirect_to(search_path)
        end
      end

      context 'when parameters include the sort_by_furthest_closing_date jobs_sort option' do
        let(:params) { search_params.merge(jobs_sort: 'sort_by_furthest_closing_date') }
        let(:expanded_search_params) { { sort_column: 'expires_on', sort_order: 'desc' } }

        it 'redirects to the full search path' do
          expect(subject).to redirect_to(search_path)
        end
      end
    end

    context 'feature flagging' do
      render_views

      context 'when the email alerts feature flag is set to true' do
        before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }

        it 'shows the subscribe link' do
          get :index, params: { subject: 'English' }
          expect(response.body).to match(I18n.t('subscriptions.link.text'))
        end
      end

      context 'when the email alerts feature flag is set to false' do
        before { allow(EmailAlertsFeature).to receive(:enabled?) { false } }

        it 'does not show the subscribe link' do
          get :index, params: { subject: 'English' }
          expect(response.body).to_not match(I18n.t('subscriptions.link.text'))
        end
      end
    end
  end

  describe '#show' do
    subject { get :show, params: params }

    context 'when vacancy is trashed' do
      let(:vacancy) { create(:vacancy, :trashed) }
      let(:params) { { id: vacancy.id } }

      it 'renders errors/trashed_vacancy_found' do
        expect(subject).to render_template('errors/trashed_vacancy_found')
      end

      it 'returns not found' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when vacancy does not exist' do
      let(:params) { { id: 'missing-id' } }

      it 'renders errors/not_found' do
        expect(subject).to render_template('errors/not_found')
      end

      it 'returns not found' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the vacancy is visited by a robot' do
      before { request.env['HTTP_USER_AGENT'] = 'Googlebot' }

      let(:vacancy) { create(:vacancy) }
      let(:params) { { id: vacancy.slug } }
      let(:vacancy_page_view) { instance_double(VacancyPageView) }

      it 'should not call the track method' do
        expect(VacancyPageView).not_to receive(:new).with(vacancy)

        subject
      end
    end

    context 'when using cookies' do
      let(:vacancy) { create(:vacancy) }
      let(:params) { { id: vacancy.slug } }
      let(:vacancy_page_view) { instance_double(VacancyPageView) }

      it 'should call the track method if cookies not set' do
        expect(VacancyPageView).to receive(:new).with(vacancy).and_return(vacancy_page_view)
        expect(vacancy_page_view).to receive(:track)

        subject
      end

      it 'should not call the track method if smoke_test cookies set' do
        expect(VacancyPageView).not_to receive(:new).with(vacancy)
        cookies[:smoke_test] = '1'

        subject
      end
    end
  end
end
