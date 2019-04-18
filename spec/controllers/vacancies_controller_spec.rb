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
            subject: "<body onload=alert('test1')>Text</body>",
            location: "<img src='http://url.to.file.which/not.exist' onerror=alert(document.cookie);>",
            minimum_salary: '<xml>Foo</xml',
            phase: '<iframe>Foo</iframe>',
            working_pattern: '<script>Foo</script>',
          }
        end

        it 'passes only safe values to VacancyFilters' do
          expected_safe_values = {
            'subject' => 'Text',
            'location' => '',
            'minimum_salary' => 'Foo',
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
    end

    context 'feature flagging' do
      render_views

      context 'when the email alerts feature flag is set to true' do
        before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }

        it 'shows the subscribe link' do
          get :index, params: { subject: 'English' }
          expect(response.body).to match(I18n.t('subscriptions.button'))
        end
      end

      context 'when the email alerts feature flag is set to false' do
        before { allow(EmailAlertsFeature).to receive(:enabled?) { false } }

        it 'does not show the subscribe link' do
          get :index, params: { subject: 'English' }
          expect(response.body).to_not match(I18n.t('subscriptions.button'))
        end
      end
    end
  end
end
