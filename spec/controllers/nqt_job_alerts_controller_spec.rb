require 'rails_helper'

RSpec.describe NqtJobAlertsController, type: :controller do
  let(:keywords) { 'something' }
  let(:location) { 'some place' }
  let(:email) { 'test@gmail.com' }

  let(:form_inputs) { { keywords: keywords, location: location, email: email } }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#new' do
    let(:params) { form_inputs }
    let(:subject) { get :new, params: params }

    it 'returns 200' do
      subject
      expect(response.code).to eql('200')
    end
  end

  describe '#create' do
    let(:params) { { nqt_job_alerts_form: form_inputs } }
    let(:search_criteria) do
      { keyword: "nqt #{keywords}", location: location, radius: 10 }.to_json
    end
    let(:subscription) { Subscription.last }
    let(:subject) { post :create, params: params }

    it 'returns 200' do
      subject
      expect(response.code).to eql('200')
    end

    it 'queues a job to audit the subscription' do
      expect { subject }.to have_enqueued_job(AuditSubscriptionCreationJob)
    end

    it 'calls SubscriptionMailer' do
      expect(SubscriptionMailer).to receive_message_chain(:confirmation, :deliver_later)
      subject
    end

    it 'creates a subscription' do
      expect { subject }.to change { Subscription.count }.by(1)
      expect(subscription.email).to eq(email)
      expect(subscription.search_criteria).to eq(search_criteria)
    end

    context 'when parameters include syntax' do
      let(:keywords) { "<body onload=alert('test1')>Text</script>" }
      let(:expected_safe_values) { { keywords: 'Text', location: location, email: email } }

      it 'sanitizes form inputs' do
        subject
        expect(controller.send(:nqt_job_alerts_params)).to eq(
          ActionController::Parameters.new(expected_safe_values).permit(:keywords, :location, :email)
        )
      end
    end
  end
end
