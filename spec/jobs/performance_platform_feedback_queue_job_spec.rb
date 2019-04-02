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
    stub_const('PP_USER_SATISFACTION_TOKEN', 'user-satisfaction-token')

    user_satisfaction = double(:user_satisfaction)

    today = Date.current.beginning_of_day.in_time_zone
    two_days_ago = today - 2.days

    create_list(:feedback, 3, rating: 1, created_at: today)
    create_list(:feedback, 4, rating: 4, created_at: two_days_ago)

    rating3 = create_list(:feedback, 2, rating: 3, created_at: date_to_upload)
    rating5 = create_list(:feedback, 3, rating: 5, created_at: date_to_upload)

    ratings = {
      1 => 0,
      2 => 0,
      3 => rating3.count,
      4 => 0,
      5 => rating5.count
    }

    expect(PerformancePlatform::UserSatisfaction).to receive(:new)
      .with('user-satisfaction-token')
      .and_return(user_satisfaction)
    expect(user_satisfaction).to receive(:submit).with(ratings, date_to_upload.iso8601)

    perform_enqueued_jobs { job }
  end
end
