require "rails_helper"

RSpec.describe VacancyAnalyticsService do
  let(:vacancy) { create(:vacancy) }
  let(:referrer_url) { "https://example.com/some/path?utm=source" }
  let(:normalized_referrer) { "example.com" }
  let(:redis_key) { "vacancy_referrer_stats:#{vacancy.id}:#{normalized_referrer}" }

  before do
    mock_redis = MockRedis.new
    allow(Redis).to receive(:current).and_return(mock_redis)
    # Manually stub scan_each to return all keys at once, mock_redis doesn't seem to be able to do this as standard
    allow(mock_redis).to receive(:scan_each) { mock_redis.keys.each }
    Redis.current.del(redis_key)
  end

  describe ".track_visit" do
    it "increments the Redis counter for a normalized referrer" do
      expect {
        described_class.track_visit(vacancy.id, referrer_url)
      }.to change { Redis.current.get(redis_key).to_i }.by(1)
    end

    it "does nothing if vacancy id is blank" do
      expect {
        described_class.track_visit(nil, referrer_url)
      }.not_to(change { Redis.current.keys("vacancy_referrer_stats:*").count })
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
    let(:key) { "vacancy_referrer_stats:#{Date.current}:#{vacancy.id}:#{normalized_referrer}" }
    let(:second_key) { "vacancy_referrer_stats:#{Date.current}:#{vacancy.id}:another.com" }

    it "upserts the correct stat into the database and deletes the Redis key" do
      Redis.current.set(key, 5)
      Redis.current.set(second_key, 3)

      # Add enough Redis keys to ensure that `aggregate_and_save_stats` processes multiple batches.
      # Tests that keys beyond the first `each_slice(100)` batch are still correctly handled (and satisfies code coverage standards).
      99.times do |i|
        another_key = "vacancy_referrer_stats:#{Date.current}:#{vacancy.id}:ref#{i}.com"
        Redis.current.set(another_key, 1)
      end

      expect {
        described_class.aggregate_and_save_stats
      }.to change(VacancyAnalytics, :count).by(101)

      # test that we delete keys after aggregating and saving stats.
      expect(Redis.current.exists?(key)).to be(false)
      expect(Redis.current.exists?(second_key)).to be(false)

      first_referrer_vacancy_analytics = VacancyAnalytics.find_by(referrer_url: normalized_referrer)
      second_referrer_vacancy_analytics = VacancyAnalytics.find_by(referrer_url: "another.com")

      expect(first_referrer_vacancy_analytics.vacancy_id).to eq(vacancy.id)
      expect(first_referrer_vacancy_analytics.date).to eq(Date.current)
      expect(first_referrer_vacancy_analytics.visit_count).to eq(5)

      expect(second_referrer_vacancy_analytics.vacancy_id).to eq(vacancy.id)
      expect(second_referrer_vacancy_analytics.date).to eq(Date.current)
      expect(second_referrer_vacancy_analytics.visit_count).to eq(3)
    end

    it "skips keys with zero counts" do
      Redis.current.set(redis_key, 0)

      expect {
        described_class.aggregate_and_save_stats
      }.not_to change(VacancyAnalytics, :count)
    end
  end
end
