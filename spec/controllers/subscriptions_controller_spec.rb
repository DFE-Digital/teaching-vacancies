require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#new' do
    subject { get :new, params: { search_criteria: { keyword: 'english' } } }

    it 'returns 200' do
      subject
      expect(response.code).to eq('200')
    end
  end

  describe '#create' do
    let(:params) do
      {
        subscription: {
          email: 'foo@email.com',
          frequency: 'daily',
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
          }
        }
      end

      it 'does not create a subscription' do
        expect { subject }.to change { Subscription.count }.by(0)
      end
    end
  end

  describe '#edit' do
    let(:subscription) { create(:subscription, email: 'bob@dylan.com', frequency: :daily) }

    subject { get :edit, params: { id: subscription.token } }

    it 'returns 200' do
      subject
      expect(response.code).to eq('200')
    end
  end

  describe '#update' do
    let(:subscription) { create(:subscription, email: 'bob@dylan.com', frequency: :daily) }

    let(:params) do
      {
        email: 'jimi@hendrix.com',
        frequency: 'weekly',
        search_criteria: { keyword: 'english' }.to_json
      }
    end
    let!(:subject) { put :update, params: { id: subscription.token, subscription: params } }

    it 'returns 200' do
      expect(response.code).to eq('200')
    end

    it 'updates a subscription' do
      expect(subscription.reload.email).to eq('jimi@hendrix.com')
      expect(subscription.reload.search_criteria).to eq(params[:search_criteria])
    end

    context 'with unsafe params' do
      let(:params) do
        {
          email: '<script>foo@email.com</script>',
          search_criteria: "<body onload=alert('test1')>Text</body>",
        }
      end

      it 'does not update a subscription' do
        expect(subscription.reload.email).to eq('bob@dylan.com')
      end
    end
  end
end
