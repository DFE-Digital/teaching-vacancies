require "rails_helper"

RSpec.describe VacancyAnalyticsService do
  let(:vacancy) { create(:vacancy) }
  let(:referrer_url) { "https://www.example.com/some/path?utm=source" }
  let(:hostname) { "www.tvs.service.gov.uk" }
  let(:test_redis_key) { "example" }
  let(:mock_redis) { MockRedis.new }

  before do
    allow(described_class).to receive(:redis).and_return(mock_redis)
    # Manually stub scan_each to return all keys at once, mock_redis doesn't seem to be able to do this as standard
    allow(mock_redis).to receive(:scan_each) { mock_redis.keys.each }
  end

  describe ".track_visit" do
    let(:redis_key) { "vacancy_referrer_stats:#{vacancy.id}:#{test_redis_key}" }

    it "increments the Redis counter for a normalized referrer" do
      expect {
        described_class.track_visit(vacancy.id, referrer_url, hostname, {})
      }.to change { mock_redis.get(redis_key).to_i }.by(1)
    end

    it "does nothing if vacancy id is blank" do
      expect {
        described_class.track_visit(nil, referrer_url, hostname, {})
      }.not_to(change { mock_redis.keys("vacancy_referrer_stats:*").count })
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

  describe ".aggregate_and_save_stats" do
    let(:key) { "vacancy_referrer_stats:#{vacancy.id}:#{test_redis_key}" }
    let(:second_key) { "vacancy_referrer_stats:#{vacancy.id}:another" }
    let(:third_key) { "vacancy_referrer_stats:#{another_vacancy.id}:#{test_redis_key}" }
    let(:another_vacancy) { create(:vacancy) }

    before do
      create(:vacancy_analytics, vacancy: another_vacancy, referrer_counts: { "example" => 2 })
    end

    it "upserts the correct stat into the database and deletes the Redis key" do
      mock_redis.set(key, 5)
      mock_redis.set(second_key, 3)
      mock_redis.set(third_key, 1)

      # test that we create one new vacancy_analytics, we are updating the existing one.
      expect { described_class.aggregate_and_save_stats }.to change(VacancyAnalytics, :count).by(1)

      # test that we delete keys after aggregating and saving stats.
      expect(mock_redis.exists?(key)).to be(false)
      expect(mock_redis.exists?(second_key)).to be(false)

      vacancy_analytics_1 = VacancyAnalytics.find_by(vacancy_id: vacancy.id)
      vacancy_analytics_2 = VacancyAnalytics.find_by(vacancy_id: another_vacancy.id)

      expect(vacancy_analytics_1.referrer_counts).to eq({ "example" => 5, "another" => 3 })
      expect(vacancy_analytics_2.referrer_counts).to eq({ "example" => 3 })
    end

    it "skips keys with zero counts" do
      mock_redis.set(key, 0)
      mock_redis.set(second_key, 3)

      described_class.aggregate_and_save_stats

      vacancy_analytics_1 = VacancyAnalytics.find_by(vacancy_id: vacancy.id)
      expect(vacancy_analytics_1.referrer_counts).to eq({ "another" => 3 })
    end
  end

  describe ".update_stats_in_database" do
    it "merges referrer counts correctly" do
      existing = create(:vacancy_analytics, vacancy: vacancy, referrer_counts: { "google" => 2 })

      described_class.update_stats_in_database({
        vacancy.id => { "google" => 3 },
      })

      expect(existing.reload.referrer_counts["google"]).to eq(5)
    end

    it "ignores the update if the vacancy trying no longer exists" do
      deleted_vacancy_id = SecureRandom.uuid
      original_count = VacancyAnalytics.count

      expect {
        described_class.update_stats_in_database({
          deleted_vacancy_id => { "google" => 3 },
        })
      }.not_to raise_error
      expect(VacancyAnalytics.count).to eq(original_count)
    end
  end
end
