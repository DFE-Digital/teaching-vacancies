require 'rails_helper'
RSpec.describe ':vacancies' do
  context ':performance_platform' do
    context ':submit_transactions' do
      it 'returns the Vacancy count for the previous day' do
        stub_const('PP_TRANSACTIONS_BY_CHANNEL_TOKEN', 'not-nil')

        published_yesterday = build_list(:vacancy, 3, :published_slugged, publish_on: 1.day.ago)
        published_yesterday.each { |v| v.save(validate: false) }

        pp = double(:performance_platform)
        now = Time.zone.now
        allow(Time).to receive_message_chain(:zone, :now).and_return(now)
        expect(PerformancePlatform::TransactionsByChannel).to receive(:new).with('not-nil').and_return(pp)
        expect(pp).to receive(:submit_transactions).with(3, (now - 1.day).utc.iso8601)

        Rake::Task['performance_platform:submit_transactions'].invoke
      end
    end
  end
end
