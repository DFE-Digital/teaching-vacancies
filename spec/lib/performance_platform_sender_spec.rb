require 'rails_helper'
require 'performance_platform_sender'

RSpec.describe PerformancePlatformSender::Base do
  let(:type) { :transactions }
  let(:date) { (Date.current.beginning_of_day.in_time_zone - 1.day).to_s }
  let(:parsed_date) { Time.zone.parse(date) }

  subject { described_class.by_type(type) }

  it 'will return the correct class for type' do
    expect(subject).to be_a(PerformancePlatformSender::Transactions)
  end

  context 'transactions' do
    subject { described_class.by_type(type).call(date: date) }

    it 'will submit transaction data' do
      data = {}

      expect(Vacancy).to receive(:published_on_count).and_return(data)

      transaction_by_channel = instance_double(PerformancePlatform::TransactionsByChannel)
      expect(PerformancePlatform::TransactionsByChannel).to receive(:new).and_return(transaction_by_channel)
      expect(transaction_by_channel).to receive(:submit).with(data, parsed_date)

      subject

      expect(TransactionAuditor.last.success?).to be true
    end

    it 'will be idempotent' do
      TransactionAuditor::Logger.new('performance_platform:submit_transactions', parsed_date).log_success

      expect(PerformancePlatform::TransactionsByChannel).to_not receive(:new)
      expect(Vacancy).to_not receive(:published_on_count)

      subject
    end

    it 'will log a failure' do
      allow_any_instance_of(PerformancePlatform::TransactionsByChannel)
        .to receive(:submit).and_raise(RuntimeError.new('Error'))

      expect { subject }.to raise_error(RuntimeError)

      expect(TransactionAuditor.last.success?).to be false
    end
  end

  context 'feedback' do
    let(:type) { :feedback }

    subject { described_class.by_type(type).call(date: date) }

    it 'will submit feedback data' do
      data = { 1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0 }

      expect(Feedback).to receive_message_chain(:published_on, :group, :count).and_return(data)

      user_feedback = instance_double(PerformancePlatform::UserSatisfaction)
      expect(PerformancePlatform::UserSatisfaction).to receive(:new).and_return(user_feedback)
      expect(user_feedback).to receive(:submit).with(data, parsed_date)

      subject

      expect(TransactionAuditor.last.success?).to be true
    end
  end
end
