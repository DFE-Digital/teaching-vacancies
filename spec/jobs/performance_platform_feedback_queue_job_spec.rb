require 'rails_helper'

RSpec.describe PerformancePlatformFeedbackQueueJob, type: :job do
  include ActiveJob::TestHelper

  subject(:date) { Date.current.beginning_of_day }
  subject(:job) { described_class.perform_later(date.to_s) }

  it 'queues the job' do
    expect { job }.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
  end

  it 'is in the performance_platform queue' do
    expect(PerformancePlatformFeedbackQueueJob.new.queue_name).to eq('performance_platform')
  end

  it 'executes perform' do
    stub_const('PP_USER_SATISFACTION_TOKEN', 'user-satisfaction-token')

    user_satisfaction = double(:user_satisfaction)

    feedback = create_list(:feedback, 2, rating: 3, created_at: date)
    feedback << create_list(:feedback, 3, rating: 5, created_at: date)
    feedback.flatten!

    ratings = { 1 => 0, 2 => 0, 3 => 2, 4 => 0, 5 => 3 }

    expect(PerformancePlatform::UserSatisfaction).to receive(:new)
      .with('user-satisfaction-token')
      .and_return(user_satisfaction)
    expect(user_satisfaction).to receive(:submit).with(ratings, date.utc.iso8601)

    perform_enqueued_jobs { job }
  end
end
