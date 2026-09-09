class VacancyAnalyticsService
  class << self
    def track_visit(vacancy_id:, referrer_url:, hostname:, params:)
      return if vacancy_id.blank?

      referrer = normalize_referrer(referrer_url, hostname, params)

      # VacancyAnalytics.connection.exec_query(<<~SQL.squish, "track_visit", [vacancy_id, referrer])
      #   INSERT INTO vacancy_analytics (id, vacancy_id, referrer_counts, created_at, updated_at)
      #   VALUES (gen_random_uuid(), $1, jsonb_build_object($2::text, 1), now(), now())
      #   ON CONFLICT (vacancy_id) DO UPDATE
      #   SET referrer_counts = jsonb_set(
      #         vacancy_analytics.referrer_counts,
      #         ARRAY[$2::text],
      #         to_jsonb(COALESCE((vacancy_analytics.referrer_counts ->> $2::text)::bigint, 0) + 1)),
      #       updated_at = now()
      # SQL
      VacancyAnalytics.transaction do
        analytics = VacancyAnalytics.where(vacancy_id: vacancy_id).lock(true).first_or_initialize

        new_count = analytics.referrer_counts.fetch(referrer, 0) + 1
        analytics.referrer_counts[referrer] = new_count
        analytics.save!
      end
    end

    # def self.update_stats_in_database(vacancy_updates)
    #   vacancy_updates.each do |vacancy_id, new_referrer_counts|
    #     # Skip if the associated vacancy does not exist. This may happen if the vacancy was deleted after the visit was tracked.
    #     next unless PublishedVacancy.exists?(id: vacancy_id)
    #
    #     VacancyAnalytics.transaction do
    #       analytics = VacancyAnalytics.where(vacancy_id: vacancy_id).lock(true).first_or_initialize
    #
    #       merged_counts = analytics.referrer_counts.merge(new_referrer_counts) do |_, old_count, new_count|
    #         old_count.to_i + new_count.to_i
    #       end
    #
    #       analytics.referrer_counts = merged_counts
    #       analytics.save!
    #     end
    #   end
    # end

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
