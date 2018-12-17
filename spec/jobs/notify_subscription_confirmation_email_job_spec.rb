require 'rails_helper'

RSpec.describe NotifySubscriptionConfirmationEmailJob, type: :job do
  include ActiveJob::TestHelper

  subject(:job) { described_class.perform_later(subscription.id) }
  let(:subscription) { create(:daily_subscription) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the notify_request queue' do
    expect(job.queue_name).to eq('notify_request')
  end

  it 'triggers the confirmation service' do
    confirmation_email = double(:mock)
    expect(SubscriptionConfirmationEmail).to receive(:new)
      .with(subscription).and_return(confirmation_email)
    expect(confirmation_email).to receive(:call)

    perform_enqueued_jobs { job }
  end
end
