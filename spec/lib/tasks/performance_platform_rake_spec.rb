require 'rails_helper'
RSpec.describe 'rake performance_platform:submit_transactions', type: :task do
  it 'Submits job publication transactions for the previous day' do
    today = Date.current.beginning_of_day.in_time_zone
    expect(Date).to receive_message_chain(:current, :beginning_of_day).and_return(today)

    expect(PerformancePlatformTransactionsQueueJob).to receive(:perform_later).with((today - 1.day).to_s)

    task.invoke
  end
end

RSpec.describe 'rake performance_platform:submit_user_satisfaction', type: :task do
  it 'Submits user satisfaction for the previous day' do
    today = Date.current.beginning_of_day.in_time_zone
    expect(Date).to receive_message_chain(:current, :beginning_of_day).and_return(today)

    expect(PerformancePlatformFeedbackQueueJob).to receive(:perform_later).with((today - 1.day).to_s)

    task.invoke
  end
end
