require "rails_helper"

RSpec.describe RemoveJobsThatExpiredYesterdayFromGoogleIndexJob do
  let(:urls) { Vacancy.expired_yesterday.map { |vacancy| job_url(vacancy) } }

  before do
    create_list(:vacancy, 5, expires_at: 1.day.ago)
    create_list(:vacancy, 1, expires_at: 2.days.ago)
    create_list(:vacancy, 1, :published)
  end

  it "executes RemoveGoogleIndexQueueJob for each expired vacancy" do
    urls.each { |url| expect(RemoveGoogleIndexQueueJob).to receive(:perform_now).with(url) }

    perform_enqueued_jobs { described_class.perform_later }
  end
end
