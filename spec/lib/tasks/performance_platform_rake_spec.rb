require 'rails_helper'
RSpec.describe 'rake performance_platform:submit_transactions', type: :task do
  it 'Submits job publication transactions for the previous day' do
    now = Date.current.beginning_of_day
    expect(Date).to receive_message_chain(:current, :beginning_of_day).and_return(now)

    stub_const('PP_TRANSACTIONS_BY_CHANNEL_TOKEN', 'not-nil')

    pp = double(:performance_platform)

    published_yesterday = build_list(:vacancy, 3, :published_slugged, publish_on: now - 2.days)
    published_yesterday.each { |v| v.save(validate: false) }

    expect(PerformancePlatform::TransactionsByChannel).to receive(:new).with('not-nil').and_return(pp)
    expect(pp).to receive(:submit_transactions).with(3, (now - 1.day).utc.iso8601)

    task.invoke
  end
end

RSpec.describe 'rake performance_platform:submit_user_satisfaction', type: :task do
  it 'Submits user satisfaction for the previous day' do
    now = Date.current.beginning_of_day
    expect(Date).to receive_message_chain(:current, :beginning_of_day).and_return(now)

    stub_const('PP_USER_SATISFACTION_TOKEN', 'user-satisfaction-token')

    user_satisfaction = double(:user_satisfaction)

    feedback = create_list(:feedback, 2, rating: 3, created_at: 2.days.ago)
    feedback << create_list(:feedback, 3, rating: 5, created_at: 2.days.ago)
    feedback.flatten!

    ratings = { 1 => 0, 2 => 0, 3 => 2, 4 => 0, 5 => 3 }

    expect(PerformancePlatform::UserSatisfaction).to receive(:new)
      .with('user-satisfaction-token')
      .and_return(user_satisfaction)
    expect(user_satisfaction).to receive(:submit).with(ratings, (now - 1.day).utc.iso8601)

    task.invoke
  end
end
