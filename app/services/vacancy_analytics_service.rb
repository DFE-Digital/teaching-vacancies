class VacancyAnalyticsService
  REDIS_KEY_PREFIX = "vacancy_referrer_stats".freeze

  def self.track_visit(vacancy_id, referrer_url)
    return if vacancy_id.blank?

    # Normalize the referrer URL (remove query params, etc.)
    normalized_referrer = normalize_referrer(referrer_url)

    # Generate a Redis key for today's visits for this vacancy and referrer
    redis_key = "#{REDIS_KEY_PREFIX}:#{vacancy_id}:#{normalized_referrer}"
    # Increment the counter in Redis
    Redis.current.incr(redis_key)
  end

  def self.aggregate_and_save_stats
    today = Date.current.to_s
    keys_pattern = "#{REDIS_KEY_PREFIX}:#{today}:*"

    Redis.current.scan_each(match: keys_pattern).each_slice(100) do |keys_batch|
      stats_to_update = []
      keys_to_delete = []

      keys_batch.each do |key|
        count = Redis.current.get(key).to_i
        next if count.zero?

        # Parse key to extract vacancy_id and referrer
        _, date, vacancy_id, referrer = key.split(":", 4)

        stats_to_update << { vacancy_id: vacancy_id, referrer_url: referrer, date: Date.parse(date), count: count }
        keys_to_delete << key
      end

      update_stats_in_database(stats_to_update) if stats_to_update.any?
      Redis.current.del(*keys_to_delete)
    end
  end

  def self.update_stats_in_database(stats_batch)
    stats_batch.each do |stat|
      # Use upsert to avoid race conditions and reduce DB operations
      VacancyAnalytics.upsert(
        {
          vacancy_id: stat[:vacancy_id],
          referrer_url: stat[:referrer_url],
          date: stat[:date],
          visit_count: stat[:count],
        },
        on_duplicate: Arel.sql("visit_count = vacancy_analytics.visit_count + #{stat[:count]}"),
      )
    end
  end

  def self.normalize_referrer(url)
    return "direct" if url.blank?

    begin
      uri = URI.parse(url)
      # Just keep the host (domain) part of the referrer
      uri.host.presence || "unknown"
    rescue URI::InvalidURIError
      "invalid"
    end
  end
end
