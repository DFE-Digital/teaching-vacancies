require 'rails_helper'

RSpec.describe SendFinalSubscriptionExpiryAlertsJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the send_expiry_alerts queue' do
    expect(job.queue_name).to eq('send_expiry_alerts')
  end

  context 'when job is run' do
    let!(:expiring_next_week) { create_list(:subscription, 3, expires_on: 1.week.from_now.to_date) }
    let!(:due_final_expiry_notice) { create_list(:subscription, 3, expires_on: 1.day.from_now.to_date) }
    let(:mailer) { double(:mailer) }

    it 'sends emails to the right subscriptions' do
      due_final_expiry_notice.each do |s|
        expect(SubscriptionExpiryMailer).to receive(:final_expiry_warning).with(s.id) { mailer }
        expect(mailer).to receive(:deliver_later)
      end

      expiring_next_week.each do |s|
        expect(SubscriptionExpiryMailer).to_not receive(:first_expiry_warning).with(s.id)
      end

      perform_enqueued_jobs { job }
    end
  end
end