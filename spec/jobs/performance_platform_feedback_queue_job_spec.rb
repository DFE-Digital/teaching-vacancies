require 'rails_helper'

RSpec.describe PerformancePlatformFeedbackQueueJob, type: :job do
  include ActiveJob::TestHelper

  subject(:date_to_upload) { Date.current.beginning_of_day.in_time_zone - 1.day }
  subject(:job) { described_class.perform_later(date_to_upload.to_s) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the performance_platform queue' do
    expect(PerformancePlatformFeedbackQueueJob.new.queue_name).to eq('performance_platform')
  end

  it 'executes perform' do
    pp = instance_double(PerformancePlatformSender::Feedback)

    expect(PerformancePlatformSender::Base).to receive(:by_type).with(:feedback).and_return(pp)
    expect(pp).to receive(:call).with(date: date_to_upload.to_s)

    perform_enqueued_jobs { job }
  end
end
