# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrackVacancyViewJob do
  let(:vacancy) { create(:vacancy) }
  let(:referrer_url) { "https://www.example.com/some/path?utm=source" }
  let(:hostname) { "www.tvs.service.gov.uk" }

  it "calls track_visits" do
    expect {
      described_class.perform_now(vacancy_id: vacancy.id, referrer_url: referrer_url, hostname: hostname, params: {})
    }.to change(VacancyAnalytics, :count).by(1)
  end
end
