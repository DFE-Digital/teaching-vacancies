class SitemapController < ApplicationController
  STATIC_PAGES = %w[terms-and-conditions savings-methodology accessibility vision-statement].freeze
  POST_SECTION_NAMES = %w[get-help-hiring jobseeker-guides].freeze

  def show
    map = XmlSitemap::Map.new(service_domain, secure: !Rails.env.development?) do |sitemap|
      add_live_vacancies(sitemap)

      add_static_landing_pages(sitemap)

      add_location_landing_pages(sitemap)

      STATIC_PAGES.each { |static_page| sitemap.add page_path(static_page), period: "weekly" }

      add_all_posts(sitemap)
    end

    expires_in 3.hours
    render xml: map.render
  end

  private

  def add_live_vacancies(sitemap)
    PublishedVacancy.live.applicable.find_each do |vacancy|
      sitemap.add job_path(vacancy), updated: vacancy.updated_at, expires: vacancy.expires_at, period: "hourly", priority: 0.7
    end
  end

  def add_static_landing_pages(sitemap)
    Rails.application.config.landing_pages.each_key do |landing_page|
      sitemap.add landing_page_path(landing_page), period: "hourly"
    end
  end

  def add_location_landing_pages(sitemap)
    (ALL_IMPORTED_LOCATIONS + REDIRECTED_LOCATION_LANDING_PAGES.values - REDIRECTED_LOCATION_LANDING_PAGES.keys).map(&:parameterize).uniq.each do |location|
      sitemap.add location_landing_page_path(location.parameterize), period: "hourly"
    end
  end

  def add_all_posts(sitenap)
    POST_SECTION_NAMES.each do |section|
      sitenap.add posts_path(section), period: "weekly"

      MarkdownDocument.all_subcategories(section).each do |sub_category|
        sitenap.add subcategory_path(section, sub_category.post_name), period: "weekly"
        posts = MarkdownDocument.all(section, sub_category.post_name)
        posts.each do |post|
          sitenap.add post_path(section, sub_category.post_name, post.post_name), period: "weekly"
        end
      end
    end
  end
end
