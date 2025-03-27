require "rails_helper"

RSpec.describe VacancyAnalyticsService do
  let(:vacancy_id) { SecureRandom.uuid }
  let(:referrer_url) { "https://example.com/some/path?utm=source" }
  let(:normalized_referrer) { "example.com" }
  let(:redis_key) { "vacancy_referrer_stats:#{vacancy_id}:#{normalized_referrer}" }

  before do
    # Use fresh Redis DB (or clear key)
    mock_redis = MockRedis.new
    allow(Redis).to receive(:current).and_return(mock_redis)

    Redis.current.del(redis_key)
  end

  describe ".track_visit" do
    it "increments the Redis counter for a normalized referrer" do
      expect {
        described_class.track_visit(vacancy_id, referrer_url)
      }.to change { Redis.current.get(redis_key).to_i }.by(1)
    end

    it "does nothing if vacancy_id is blank" do
      expect {
        described_class.track_visit(nil, referrer_url)
      }.not_to(change { Redis.current.keys("vacancy_referrer_stats:*").count })
    end

    it "skips keys with zero counts" do
      Redis.current.set(redis_key, 0)
    
      expect {
        described_class.aggregate_and_save_stats
      }.not_to change(VacancyAnalytics, :count)
    
      expect(Redis.current.get(key)).to eq("0") # key is not deleted
    end
  end

  describe ".normalize_referrer" do
    it "returns the host from a valid URL" do
      expect(described_class.normalize_referrer("https://google.com/whatever")).to eq("google.com")
    end

    it "returns 'direct' for a blank URL" do
      expect(described_class.normalize_referrer(nil)).to eq("direct")
    end

    it "returns 'invalid' for malformed URLs" do
      expect(described_class.normalize_referrer("%%%")).to eq("invalid")
    end
  end

  describe ".aggregate_and_save_stats" do
    let(:key) { "vacancy_referrer_stats:#{Date.current}:#{vacancy_id}:#{normalized_referrer}" }

    before do
      Redis.current.set(key, 5)
    end

    it "upserts the correct stat into the database and deletes the Redis key" do
      expect {
        described_class.aggregate_and_save_stats
      }.to change(VacancyAnalytics, :count).by(1)

      expect(Redis.current.get(key)).to be_nil

      stat = VacancyAnalytics.last
      expect(stat.vacancy_id).to eq(vacancy_id)
      expect(stat.referrer_url).to eq(normalized_referrer)
      expect(stat.date).to eq(Date.current)
      expect(stat.visit_count).to eq(5)
    end
  end
end
