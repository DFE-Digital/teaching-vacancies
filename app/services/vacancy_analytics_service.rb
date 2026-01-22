class VacancyAnalyticsService
  REDIS_KEY_PREFIX = "vacancy_referrer_stats".freeze

  def self.track_visit(vacancy_id, referrer_url, hostname, params)
    return if vacancy_id.blank?

    # Generate a Redis key for this vacancy and referrer
    redis_key = "#{REDIS_KEY_PREFIX}:#{vacancy_id}:#{normalize_referrer(referrer_url, hostname, params)}"
    # Increment the counter in Redis
    redis.incr(redis_key)
  end

  def self.aggregate_and_save_stats
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

      update_stats_in_database(updates_by_vacancy) if updates_by_vacancy.any?
      redis.del(*keys_to_delete)
    end
  end

  def self.update_stats_in_database(vacancy_updates)
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

  class << self
    def normalize_referrer(referrer, hostname, params)
      if params[:utm_medium] == "email"
        "jobalert"
      elsif referrer.nil?
        "direct"
      else
        normalize_referrer_url referrer, hostname
      end
    end

    private

    def redis
      # :nocov:
      @redis ||= Redis.new(url: Rails.configuration.redis_cache_url)
      # :nocov:
    end

    def normalize_referrer_url(referrer, hostname)
      referrer_uri = Addressable::URI.parse(referrer)
      if referrer_uri.host.present?
        if referrer_uri.host == hostname
          "internal"
        else
          host_split = referrer_uri.host.split(".")
          tld_split = referrer_uri.tld.split(".")

          (host_split - tld_split).last
        end
      else
        "internal"
      end
    rescue PublicSuffix::DomainNotAllowed, Addressable::URI::InvalidURIError
      "invalid"
    end
  end
end
