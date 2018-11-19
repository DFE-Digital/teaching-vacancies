require 'rails_helper'

RSpec.describe PerformancePlatformTransactionsQueueJob, type: :job do
  include ActiveJob::TestHelper

  subject(:date) { Date.current.beginning_of_day.in_time_zone }
  subject(:job) { described_class.perform_later(date.to_s) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the performance_platform queue' do
    expect(PerformancePlatformTransactionsQueueJob.new.queue_name).to eq('performance_platform')
  end

  it 'executes perform' do
    stub_const('PP_TRANSACTIONS_BY_CHANNEL_TOKEN', 'not-nil')

    pp = double(:performance_platform)

    published = create_list(:vacancy, 3, :published, publish_on: date)

    expect(PerformancePlatform::TransactionsByChannel).to receive(:new).with('not-nil').and_return(pp)
    expect(pp).to receive(:submit_transactions).with(published.count, date.utc.iso8601)
    perform_enqueued_jobs { job }
  end
end
