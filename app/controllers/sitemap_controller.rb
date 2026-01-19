class SitemapController < ApplicationController
  STATIC_PAGES = %w[terms-and-conditions savings-methodology accessibility vision-statement].freeze
  POST_SECTION_NAMES = %w[get-help-hiring jobseeker-guides].freeze

  def show # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    map = XmlSitemap::Map.new(service_domain, secure: !Rails.env.development?) do |m|
      # Live vacancies
      PublishedVacancy.live.applicable.find_each do |vacancy|
        m.add job_path(vacancy), updated: vacancy.updated_at, expires: vacancy.expires_at, period: "hourly", priority: 0.7
      end

      # Static landing pages
      Rails.application.config.landing_pages.each_key do |landing_page|
        m.add landing_page_path(landing_page), period: "hourly"
      end

      # Location landing pages
      (ALL_IMPORTED_LOCATIONS + REDIRECTED_LOCATION_LANDING_PAGES.values - REDIRECTED_LOCATION_LANDING_PAGES.keys).map(&:parameterize).uniq.each do |location|
        m.add location_landing_page_path(location.parameterize), period: "hourly"
      end

      STATIC_PAGES.each { |static_page| m.add page_path(static_page), period: "weekly" }

      POST_SECTION_NAMES.each do |section|
        m.add posts_path(section), period: "weekly"

        MarkdownDocument.all_subcategories(section).each do |sub_category|
          m.add subcategory_path(section, sub_category.post_name), period: "weekly"
          posts = MarkdownDocument.all(section, sub_category.post_name)
          posts.each do |post|
            m.add post_path(section, sub_category.post_name, post.post_name), period: "weekly"
          end
        end
      end
      # POST_SECTIONS.each do |section, subcats|
      #   m.add posts_path(section), period: "weekly"
      #   subcats.each do |subcat, post|
      #     m.add subcategory_path(section, subcat), period: "weekly"
      #
      #     post.each do |post|
      #       m.add post_path(section, subcat, post), period: "weekly"
      #     end
      #   end
      # end
    end

    expires_in 3.hours
    render xml: map.render
  end
end
