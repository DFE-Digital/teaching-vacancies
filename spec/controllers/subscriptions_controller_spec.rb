require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#new' do
    subject { get :new, params: { search_criteria: { subject: 'english' } } }

    context 'when feature is disabled' do
      before { allow(EmailAlertsFeature).to receive(:enabled?) { false } }

      it 'returns 404' do
        subject
        expect(response.code).to eq('404')
      end
    end

    context 'when feature is enabled' do
      before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }

      it 'returns 200' do
        subject
        expect(response.code).to eq('200')
      end
    end
  end

  describe '#create' do
    context 'when feature is enabled' do
      before { allow(EmailAlertsFeature).to receive(:enabled?) { true } }
      let(:params) do
        {
          subscription: {
            email: 'foo@email.com',
            search_criteria: { keyword: 'english' }.to_json
          }
        }
      end
      let(:subject) { post :create, params: params }
      let(:subscription) { Subscription.last }

      it 'returns 200' do
        subject
        expect(response.code).to eq('200')
      end

      it 'queues a job to audit the subscription' do
        expect { subject }.to have_enqueued_job(AuditSubscriptionCreationJob)
      end

      it 'creates a subscription' do
        expect { subject }.to change { Subscription.count }.by(1)
        expect(subscription.email).to eq(params[:subscription][:email])
        expect(subscription.search_criteria).to eq(params[:subscription][:search_criteria])
      end

      context 'with unsafe params' do
        let(:params) do
          {
            subscription: {
              email: '<script>foo@email.com</script>',
              search_criteria: "<body onload=alert('test1')>Text</body>",
              frequency: "<img src='http://url.to.file.which/not.exist' onerror=alert(document.cookie);>"
            }
          }
        end

        it 'does not create a subscription' do
          expect { subject }.to change { Subscription.count }.by(0)
        end
      end
    end

    context 'when feature is disabled' do
      before { allow(EmailAlertsFeature).to receive(:enabled?) { false } }

      it 'returns 404' do
        post :create, params: { search_criteria: { subject: 'english' } }
        expect(response.code).to eq('404')
      end
    end
  end
end
