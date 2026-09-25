# frozen_string_literal: true

RSpec.describe TrackVacancyViewJob do
  let(:vacancy) { create(:vacancy) }
  let(:referrer_url) { "https://www.example.com/some/path?utm=source" }
  let(:hostname) { "www.tvs.service.gov.uk" }

  it "calls track_visits" do
    expect(VacancyAnalyticsService).to receive(:track_visit).and_call_original
    described_class.perform_now(vacancy_id: vacancy.id, referrer_url: referrer_url, hostname: hostname, params: {})
  end
end
