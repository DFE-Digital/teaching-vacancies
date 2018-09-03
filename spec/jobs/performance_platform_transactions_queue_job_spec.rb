require 'rails_helper'

RSpec.describe PerformancePlatformTransactionsQueueJob, type: :job do
  include ActiveJob::TestHelper

  subject(:date) { Date.current.beginning_of_day }
  subject(:job) { described_class.perform_later(date) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the default queue' do
    expect(PerformancePlatformTransactionsQueueJob.new.queue_name).to eq('default')
  end

  it 'executes perform' do
    stub_const('PP_TRANSACTIONS_BY_CHANNEL_TOKEN', 'not-nil')

    pp = double(:performance_platform)

    published_yesterday = build_list(:vacancy, 3, :published_slugged, publish_on: date - 1.day)
    published_yesterday.each { |v| v.save(validate: false) }

    expect(PerformancePlatform::TransactionsByChannel).to receive(:new).with('not-nil').and_return(pp)
    expect(pp).to receive(:submit_transactions).with(3, date.utc.iso8601)
    perform_enqueued_jobs { job }
  end
end
