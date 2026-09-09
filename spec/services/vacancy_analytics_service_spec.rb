require "rails_helper"

RSpec.describe VacancyAnalyticsService do
  let(:vacancy) { create(:vacancy) }
  let(:referrer_url) { "https://www.example.com/some/path?utm=source" }
  let(:hostname) { "www.tvs.service.gov.uk" }

  describe ".track_visit" do
    it "increments the Redis counter for a normalized referrer" do
      expect {
        described_class.track_visit(vacancy_id: vacancy.id, referrer_url: referrer_url, hostname: hostname, params: {})
      }.to change(VacancyAnalytics, :count).by(1)
    end

    it "does nothing if vacancy id is blank" do
      expect {
        described_class.track_visit(vacancy_id: nil, referrer_url: referrer_url, hostname: hostname, params: {})
      }.not_to(change(VacancyAnalytics, :count))
    end
  end

  describe ".normalize_referrer" do
    it "returns the hostname from a valid URL" do
      expect(described_class.normalize_referrer("https://google.com/whatever", hostname, {})).to eq("google")
    end

    it "returns 'internal' for a URL with the same host as the request" do
      expect(described_class.normalize_referrer("https://www.tvs.service.gov.uk", hostname, {})).to eq("internal")
    end

    it "returns 'internal' if the host is missing" do
      expect(described_class.normalize_referrer("/whatever", hostname, {})).to eq("internal")
    end

    it "returns 'direct' for a blank URL" do
      expect(described_class.normalize_referrer(nil, hostname, {})).to eq("direct")
    end

    it "returns 'invalid' for malformed URLs" do
      expect(described_class.normalize_referrer("rabbit://%%%", hostname, {})).to eq("invalid")
    end

    it "returns 'jobalert' if the utm_medium is set" do
      expect(described_class.normalize_referrer(referrer_url, hostname, { utm_medium: "email" })).to eq("jobalert")
    end
  end
end
