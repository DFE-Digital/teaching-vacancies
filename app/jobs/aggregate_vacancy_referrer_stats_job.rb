# TDOD: remove this job and its schedule in recurring.yml once the new DB tracking code is released
class AggregateVacancyReferrerStatsJob < ApplicationJob
  queue_as :low

  REDIS_KEY_PREFIX = "vacancy_referrer_stats".freeze

  def perform
    self.class.aggregate_and_save_stats Redis.new(url: Rails.configuration.redis_queue_url)
  end

  class << self
    def aggregate_and_save_stats(redis)
      keys_pattern = "#{REDIS_KEY_PREFIX}:*"

      redis.scan_each(match: keys_pattern).each_slice(100) do |keys_batch|
        # Creates hash that, when accessed with a missing key, assigns a new nested hash as the value. This nested hash defaults to 0 for any missing keys.
        updates_by_vacancy = Hash.new { |h, k| h[k] = Hash.new(0) }
        keys_to_delete = []

        keys_batch.each do |key|
          count = redis.get(key).to_i
          next if count.zero?

          # Parse key to extract vacancy_id and referrer
          _, vacancy_id, referrer = key.split(":", 3)

          updates_by_vacancy[vacancy_id][referrer] += count
          keys_to_delete << key
        end

        update_stats_in_database(updates_by_vacancy)
        redis.del(*keys_to_delete)
      end
    end

    def update_stats_in_database(vacancy_updates)
      vacancy_updates.each do |vacancy_id, new_referrer_counts|
        # Skip if the associated vacancy does not exist. This may happen if the vacancy was deleted after the visit was tracked.
        next unless PublishedVacancy.exists?(id: vacancy_id)

        VacancyAnalytics.transaction do
          analytics = VacancyAnalytics.where(vacancy_id: vacancy_id).lock(true).first_or_initialize

          merged_counts = analytics.referrer_counts.merge(new_referrer_counts) do |_, old_count, new_count|
            old_count.to_i + new_count.to_i
          end

          analytics.referrer_counts = merged_counts
          analytics.save!
        end
      end
    end
  end
end
