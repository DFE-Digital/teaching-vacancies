require 'rails_helper'

RSpec.describe 'rake subscription:expiry_alerts:send', type: :task do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it 'queues the vacancy job' do
    expect { task.execute }.to have_enqueued_job(SendFirstSubscriptionExpiryAlertsJob)
  end
end
