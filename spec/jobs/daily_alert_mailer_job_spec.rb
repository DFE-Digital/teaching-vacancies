require 'rails_helper'

RSpec.describe DailyAlertMailerJob, type: :job do
  include ActiveJob::TestHelper

  let(:vacancies) { create_list(:vacancy, 5) }
  let(:subscription) { create(:daily_subscription) }

  subject(:job) { AlertMailer.daily_alert(subscription.id, vacancies.pluck(:id)).deliver_later! }

  context 'if the job has not expired' do
    let!(:alert_run) { create(:alert_run, subscription: subscription) }

    it 'delivers the mail' do
      expect { perform_enqueued_jobs { job } }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context 'if the job has expired' do
    let!(:alert_run) { create(:alert_run, subscription: subscription, created_at: Time.zone.now - 5.hours) }

    it 'does not deliver the mail' do
      expect { perform_enqueued_jobs { job } }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end
end