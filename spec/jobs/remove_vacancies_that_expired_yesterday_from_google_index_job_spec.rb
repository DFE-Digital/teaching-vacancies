require "rails_helper"

RSpec.describe RemoveVacanciesThatExpiredYesterdayFromGoogleIndexJob do
  let(:urls_expired_yesterday) { Vacancy.expired_yesterday.map { |vacancy| Rails.application.routes.url_helpers.job_url(vacancy) } }
  let(:urls_for_other_vacancies) do
    Vacancy.where.not("DATE(expires_at) = ?", 1.day.ago.to_date).map { |vacancy| Rails.application.routes.url_helpers.job_url(vacancy) }
  end

  before do
    create_list(:vacancy, 5, expires_at: 1.day.ago)
    create_list(:vacancy, 1, expires_at: 2.days.ago)
    create_list(:vacancy, 1, :published)
  end

  it "removes the url for each expired vacancy" do
    urls_expired_yesterday.each { |url| expect(RemoveGoogleIndexQueueJob).to receive(:perform_now).with(url) }

    perform_enqueued_jobs { described_class.perform_later }
  end

  it "only removes the urls of vacancies that expired yesterday" do
    urls_for_other_vacancies.each { |url| expect(RemoveGoogleIndexQueueJob).to_not receive(:perform_now).with(url) }

    perform_enqueued_jobs { described_class.perform_later }
  end
end
