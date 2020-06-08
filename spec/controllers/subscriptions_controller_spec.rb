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
    context 'verify_recaptcha is true ' do
      let(:subscription) do
        create(:subscription)
      end

      let(:subscription_presenter) do
        SubscriptionPresenter.new(subscription)
      end

      let(:subscription_finder) do
        instance_double(SubscriptionFinder).as_null_object
      end

      before do
        allow(Subscription).to receive(:new).and_return(subscription)
        allow(SubscriptionFinder).to receive(:new).and_return(subscription_finder)
        allow(SubscriptionPresenter).to receive(:new).and_return(subscription_presenter)
        allow(subscription_finder).to receive(:exists?).and_return(false)
        allow(controller).to receive(:recaptcha_reply).and_return({ 'score' => 0.9 })
        allow(controller).to receive(:verify_recaptcha).and_return(true)
      end

      it 'verifies the recaptcha' do
        expect(controller).to receive(:verify_recaptcha)
        post :create, params: { subscription: subscription.attributes }
      end

      it 'sends the Subscription instance and action (both required) when it verifies the recaptcha' do
        expect(controller).to receive(:verify_recaptcha)
          .with(model: an_instance_of(Subscription), action: 'subscription')
        post :create, params: { subscription: subscription.attributes }
      end

      it 'sets the recaptcha score on the Subscription record' do
        expect(subscription).to receive(:recaptcha_score=).with(0.9)
        post :create, params: { subscription: subscription.attributes }
      end

      it 'saves the Subscription record' do
        expect(subscription).to receive(:save).at_least(:once).and_return(true)
        post :create, params: { subscription: subscription.attributes }
      end

      it 'renders the "confirm" template' do
        post :create, params: { subscription: subscription.attributes }
        expect(response).to render_template('confirm')
      end
    end

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
