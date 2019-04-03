require 'rails_helper'

RSpec.describe PerformancePlatformTransactionsQueueJob, type: :job do
  include ActiveJob::TestHelper

  let(:runtime) { Time.new(2008, 9, 1, 13, 0, 0).utc }
  let(:date_to_upload) { Date.current.beginning_of_day.in_time_zone - 1.day }

  before do
    Timecop.freeze(runtime)
  end

  after do
    Timecop.return
  end

  subject(:job) { described_class.perform_later(date_to_upload.to_s) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the performance_platform queue' do
    expect(PerformancePlatformTransactionsQueueJob.new.queue_name).to eq('performance_platform')
  end

  it 'enqueues a job to send all published job from yesterday' do
    stub_const('PP_TRANSACTIONS_BY_CHANNEL_TOKEN', 'not-nil')

    pp = double(:performance_platform)
    two_days_ago = Date.current.beginning_of_day.in_time_zone - 2.days
    today = Date.current.beginning_of_day.in_time_zone

    build(:vacancy, :past_publish, publish_on: two_days_ago).save(validate: false)
    build(:vacancy, :past_publish, publish_on: today).save(validate: false)

    jobs_published_yesterday = [
      build(:vacancy, :past_publish, publish_on: date_to_upload).save(validate: false),
      build(:vacancy, :past_publish, publish_on: date_to_upload).save(validate: false)
    ]

    expect(PerformancePlatform::TransactionsByChannel).to receive(:new).with('not-nil').and_return(pp)
    expect(pp).to receive(:submit_transactions).with(jobs_published_yesterday.count, date_to_upload.iso8601)

    perform_enqueued_jobs { job }
  end
end
