class VacancyAnalyticsService
  REDIS_KEY_PREFIX = "vacancy_referrer_stats".freeze

  def self.track_visit(vacancy_id, referrer_url)
    return if vacancy_id.blank?

    # Generate a Redis key for this vacancy and referrer
    redis_key = "#{REDIS_KEY_PREFIX}:#{vacancy_id}:#{normalize_referrer(referrer_url)}"
    # Increment the counter in Redis
    Redis.current.incr(redis_key)
  end

  def self.aggregate_and_save_stats
    keys_pattern = "#{REDIS_KEY_PREFIX}:*"

    Redis.current.scan_each(match: keys_pattern).each_slice(100) do |keys_batch|
      # Creates hash that, when accessed with a missing key, assigns a new nested hash as the value. This nested hash defaults to 0 for any missing keys.
      updates_by_vacancy = Hash.new { |h, k| h[k] = Hash.new(0) }
      keys_to_delete = []

      keys_batch.each do |key|
        count = Redis.current.get(key).to_i
        next if count.zero?

        # Parse key to extract vacancy_id and referrer
        _, vacancy_id, referrer = key.split(":", 3)

        updates_by_vacancy[vacancy_id][referrer] += count
        keys_to_delete << key
      end

      update_stats_in_database(updates_by_vacancy) if updates_by_vacancy.any?
      Redis.current.del(*keys_to_delete)
    end
  end

  def self.update_stats_in_database(vacancy_updates)
    vacancy_updates.each do |vacancy_id, new_referrer_counts|
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

  def self.normalize_referrer(url)
    return "direct" if url.blank?

    begin
      uri = URI.parse(url)
      uri.host.presence || "unknown"
    rescue URI::InvalidURIError
      "invalid"
    end
  end
end
