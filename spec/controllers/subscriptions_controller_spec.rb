require 'rails_helper'

RSpec.describe SubscriptionsController, type: :controller do
  describe '#new' do
    subject { get :new, params: { search_criteria: { keyword: 'english' } } }

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

      it 'returns 200' do
        post :create, params: { subscription: { email: 'foo@email.com' } }
        expect(response.code).to eq('200')
      end

      it 'persists only sanitised params' do
        params = {
          subscription: {
            email: '<script>foo@email.com</script>',
            search_criteria: "<body onload=alert('test1')>Text</script>",
            frequency: "<img src='http://url.to.file.which/not.exist' onerror=alert(document.cookie);>"
          }
        }

        post :create, params: params

        subscription = Subscription.last
        expect(subscription.email).to eql('foo@email.com')
        expect(subscription.search_criteria).to eql('Text')
        expect(subscription.frequency).to eql('daily')
      end
    end

    context 'when feature is disabled' do
      before { allow(EmailAlertsFeature).to receive(:enabled?) { false } }

      it 'returns 404' do
        post :create, params: { search_criteria: { keyword: 'english' } }
        expect(response.code).to eq('404')
      end
    end
  end
end
