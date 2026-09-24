require "rails_helper"

RSpec.describe AggregateVacancyReferrerStatsJob do
  let(:mock_redis) { MockRedis.new }
  let(:vacancy) { create(:vacancy) }
  let(:test_redis_key) { "example" }

  before do
    # Manually stub scan_each to return all keys at once, mock_redis doesn't seem to be able to do this as standard
    allow(mock_redis).to receive(:scan_each) { mock_redis.keys.each }
  end

  describe "#perform" do
    it "calls VacancyAnalyticsService.aggregate_and_save_stats" do
      expect(described_class).to receive(:aggregate_and_save_stats)

      described_class.new.perform
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
      expect { described_class.aggregate_and_save_stats mock_redis }.to change(VacancyAnalytics, :count).by(1)

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

      described_class.aggregate_and_save_stats mock_redis

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
