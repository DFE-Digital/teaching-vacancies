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
        let(:expected_safe_values) { { keyword: 'Text' } }
        let(:params) do
          {
            keyword: "<body onload=alert('test1')>Text</body>",
            location: "<img src='http://url.to.file.which/not.exist' onerror=alert(document.cookie);>"
          }
        end

        it 'passes only safe values to Algolia::VacancySearchBuilder' do
          expect(Algolia::VacancySearchBuilder).to receive(:new).with(expected_safe_values).and_call_original
          subject
        end
      end

      context 'sort params' do
        let(:expected_safe_values) { { jobs_sort: 'Text' } }
        let(:params) { { jobs_sort: "<body onload=alert('test1')>Text</script>" } }

        it 'passes sanitised params to Algolia::VacancySearchBuilder' do
          expect(Algolia::VacancySearchBuilder).to receive(:new).with(expected_safe_values).and_call_original
          subject
        end
      end

      context 'search auditor' do
        let(:params) { { keyword: 'Teacher' } }

        it 'should call the search auditor' do
          expect(AuditSearchEventJob).to receive(:perform_later).with(hash_including(keyword: 'Teacher'))
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
      let(:params) do
        {
          keyword: 'Business Studies',
          location: 'Torquay',
          jobs_sort: sort
        }
      end

      context 'when parameters include the sort by newest listing option' do
        let(:sort) { 'publish_on_desc' }

        it 'sets the search replica on Algolia::VacancySearchBuilder' do
          subject
          expect(controller.instance_variable_get(:@vacancies_search).search_replica).to eql("Vacancy_#{sort}")
        end
      end

      context 'when parameters include the sort by most time to apply option' do
        let(:sort) { 'expiry_time_desc' }

        it 'sets the search replica on Algolia::VacancySearchBuilder' do
          subject
          expect(controller.instance_variable_get(:@vacancies_search).search_replica).to eql("Vacancy_#{sort}")
        end
      end

      context 'when parameters include the sort by least time to apply option' do
        let(:sort) { 'expiry_time_asc' }

        it 'sets the search replica on Algolia::VacancySearchBuilder' do
          subject
          expect(controller.instance_variable_get(:@vacancies_search).search_replica).to eql("Vacancy_#{sort}")
        end
      end

      context 'when parameters do not include a keyword' do
        let(:params) do
          {
            keyword: '',
            location: 'Torquay',
            jobs_sort: ''
          }
        end

        it 'sets the search replica on Algolia::VacancySearchBuilder to the default sort strategy: newest listing' do
          subject
          expect(controller.instance_variable_get(:@vacancies_search).search_replica).to eql('Vacancy_publish_on_desc')
        end
      end
    end

    context 'feature flagging' do
      render_views

      context 'when the email alerts feature flag is set to false' do
        before { allow(EmailAlertsFeature).to receive(:enabled?) { false } }

        it 'does not show the subscribe link' do
          get :index, params: { keyword: 'English' }
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
