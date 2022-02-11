class SitemapController < ApplicationController
  def show # rubocop:disable Metrics/AbcSize
    map = XmlSitemap::Map.new(DOMAIN, secure: !Rails.env.development?) do |m|
      # Live vacancies
      Vacancy.live.applicable.find_each do |vacancy|
        m.add job_path(vacancy), updated: vacancy.updated_at, expires: vacancy.expires_at, period: "hourly", priority: 0.7
      end

      # Static landing pages
      Rails.application.config.landing_pages.each_key do |landing_page|
        m.add landing_page_path(landing_page), period: "hourly"
      end

      # Location landing pages
      ALL_IMPORTED_LOCATIONS.each do |location|
        m.add location_landing_page_path(location.parameterize), period: "hourly"
      end

      # Static pages
      m.add page_path("privacy-policy"), period: "weekly"
      m.add page_path("terms-and-conditions"), period: "weekly"
      m.add page_path("cookies"), period: "weekly"
      m.add page_path("accessibility"), period: "weekly"
    end

    expires_in 3.hours
    render xml: map.render
  end
end
