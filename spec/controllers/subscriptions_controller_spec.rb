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
            search_criteria: { subject: 'english' }.to_json
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
        expect(subscription.expires_on).to eq(6.months.from_now.to_date)
      end

      it 'sends a confirmation' do
        message_delivery = instance_double(ActionMailer::MessageDelivery)
        expect(SubscriptionMailer).to receive(:confirmation) { message_delivery }
        expect(message_delivery).to receive(:deliver_later)

        subject
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

      context 'when update is set' do
        render_views

        let(:params) do
          {
            update: true,
            subscription: {
              email: 'foo@email.com',
              search_criteria: { subject: 'english' }.to_json
            }
          }
        end

        it 'renders the update view' do
          expect(subject).to render_template(:update)
        end

        it 'does not queue an audit job' do
          expect { subject }.to_not have_enqueued_job(AuditSubscriptionCreationJob)
        end

        it 'creates a subscription' do
          expect { subject }.to change { Subscription.count }.by(1)
          expect(subscription.email).to eq(params[:subscription][:email])
          expect(subscription.search_criteria).to eq(params[:subscription][:search_criteria])
          expect(subscription.expires_on).to eq(6.months.from_now.to_date)
        end

        it 'does not send an email' do
          expect(SubscriptionMailer).to_not receive(:confirmation)
          subject
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

  describe '#renew' do
    let!(:subscription) { create(:subscription, search_criteria: { subject: 'english' }.to_json) }
    let(:token) { subscription.token_attributes }

    subject { get :renew, params: { subscription_id: token } }

    context 'when subscription still exists' do
      before do
        token = subscription.token
        allow_any_instance_of(Subscription).to receive(:token) { token }
      end

      it 'fetches the subscription' do
        subject
        expect(assigns(:subscription).id).to eq(subscription.id)
      end

      it 'sets the path to update' do
        subject
        expect(assigns(:path)).to eq(subscription_update_path(subscription_id: subscription.token))
        expect(assigns(:method)).to eq(:patch)
      end
    end

    context 'when subscription has been deleted' do
      before { subscription.delete }

      it 'intializes a subscription' do
        subject
        expect(assigns(:subscription).id).to eq(nil)
      end

      it 'sets the path to create' do
        subject
        expect(assigns(:path)).to eq(subscriptions_path(update: true))
        expect(assigns(:method)).to eq(:post)
      end
    end
  end
end
