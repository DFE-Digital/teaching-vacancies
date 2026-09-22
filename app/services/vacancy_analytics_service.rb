class VacancyAnalyticsService
  class << self
    def track_visit(vacancy_id:, referrer_url:, hostname:, params:)
      return if vacancy_id.blank?

      referrer = normalize_referrer(referrer_url, hostname, params)

      VacancyAnalytics.transaction do
        VacancyAnalytics.upsert(
          { vacancy_id: vacancy_id, referrer_counts: { referrer => 1 } },
          unique_by: :vacancy_id,
          on_duplicate: increment_referrer_count(referrer),
        )
      end
    end

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

    # jsonb has no native "increment a key", so the SET clause has to be SQL.
    # Bound, never interpolated: `referrer` derives from the Referer header.
    def increment_referrer_count(referrer)
      Arel.sql(
        VacancyAnalytics.sanitize_sql_array([<<~SQL.squish, referrer, referrer]),
          referrer_counts = jsonb_set(
            vacancy_analytics.referrer_counts,
            ARRAY[?::text],
            to_jsonb(COALESCE((vacancy_analytics.referrer_counts ->> ?)::bigint, 0) + 1)
          ),
          updated_at = now()
        SQL
      )
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
