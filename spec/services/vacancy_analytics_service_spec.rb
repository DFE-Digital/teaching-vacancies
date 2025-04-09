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
    let(:key) { "vacancy_referrer_stats:#{vacancy.id}:#{normalized_referrer}" }
    let(:second_key) { "vacancy_referrer_stats:#{vacancy.id}:another.com" }
    let(:third_key) { "vacancy_referrer_stats:#{another_vacancy.id}:#{normalized_referrer}" }
    let(:another_vacancy) { create(:vacancy) }

    before do
      create(:vacancy_analytics, vacancy: another_vacancy, referrer_counts: { "example.com" => 2 })
    end

    it "upserts the correct stat into the database and deletes the Redis key" do
      Redis.current.set(key, 5)
      Redis.current.set(second_key, 3)
      Redis.current.set(third_key, 1)

      # test that we create one new vacancy_analytics, we are updating the existing one.
      expect { described_class.aggregate_and_save_stats }.to change(VacancyAnalytics, :count).by(1)

      # test that we delete keys after aggregating and saving stats.
      expect(Redis.current.exists?(key)).to be(false)
      expect(Redis.current.exists?(second_key)).to be(false)

      vacancy_analytics_1 = VacancyAnalytics.find_by(vacancy_id: vacancy.id)
      vacancy_analytics_2 = VacancyAnalytics.find_by(vacancy_id: another_vacancy.id)

      expect(vacancy_analytics_1.referrer_counts).to eq({ "example.com" => 5, "another.com" => 3 })
      expect(vacancy_analytics_2.referrer_counts).to eq({ "example.com" => 3 })
    end

    it "skips keys with zero counts" do
      Redis.current.set(redis_key, 0)

      expect {
        described_class.aggregate_and_save_stats
      }.not_to change(VacancyAnalytics, :count)
    end
  end
end
