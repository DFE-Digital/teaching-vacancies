require 'rails_helper'

RSpec.describe SubscriptionExpiryMailerJob, type: :job do
  include ActiveJob::TestHelper

  let(:subscription) { create(:daily_subscription) }

  describe 'with a first expiry warning' do
    let(:job) { SubscriptionExpiryMailer.first_expiry_warning(subscription.id).deliver_later! }

    context 'when the email has not been set' do
      it 'sets the correct flag' do
        perform_enqueued_jobs { job }
        subscription.reload
        expect(subscription.first_reminder_sent).to eq(true)
        expect(subscription.final_reminder_sent).to eq(false)
      end

      it 'sends the email' do
        expect { perform_enqueued_jobs { job } }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when the email has already been sent' do
      let(:subscription) { create(:daily_subscription, first_reminder_sent: true) }

      it 'does not send the email again' do
        expect { perform_enqueued_jobs { job } }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end
  end

  describe 'with a final expiry warning' do
    let(:job) { SubscriptionExpiryMailer.final_expiry_warning(subscription.id).deliver_later! }

    context 'when the email has not been sent' do
      it 'sets the correct flags' do
        perform_enqueued_jobs { job }
        subscription.reload
        expect(subscription.first_reminder_sent).to eq(true)
        expect(subscription.final_reminder_sent).to eq(true)
      end

      it 'sends the email' do
        expect { perform_enqueued_jobs { job } }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'when the email has already been sent' do
      let(:subscription) { create(:daily_subscription, final_reminder_sent: true) }

      it 'does not send the email again' do
        expect { perform_enqueued_jobs { job } }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end
  end
end