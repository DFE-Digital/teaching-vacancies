class VacancyAnalyticsService
  class << self
    def track_visit(vacancy_id:, referrer_url:, hostname:, params:)
      return if vacancy_id.blank?

      referrer = normalize_referrer(referrer_url, hostname, params)

      VacancyAnalytics.transaction do
        analytics = VacancyAnalytics.where(vacancy_id: vacancy_id).lock(true).first_or_initialize

        new_count = analytics.referrer_counts.fetch(referrer, 0) + 1
        analytics.referrer_counts[referrer] = new_count
        analytics.save!
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
