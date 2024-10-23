class LandingPage
  COUNT_CACHE_DURATION = 3.hours
  COUNT_CACHE_VARIATION_SECONDS = 300

  attr_reader :slug, :criteria, :banner_image, :hidden_filters

  def self.exists?(slug)
    Rails.application.config.landing_pages.key?(slug.to_sym)
  end

  def self.[](slug)
    raise "No such landing page: '#{slug}'" unless exists?(slug)

    criteria = Rails.application.config.landing_pages[slug.to_sym]
    new(slug, criteria)
  end

  def self.matching(criteria)
    slug = Rails.application.config.landing_pages.key(criteria)
    return unless slug

    self[slug]
  end

  def self.partially_matching(criteria)
    value = criteria.values.flatten.first
    criteria = Rails.application.config.landing_pages.values.find { |c| c.values.first.include? value }
    slug = Rails.application.config.landing_pages.key(criteria)
    return unless slug

    self[slug]
  end

  def initialize(slug, criteria)
    @slug = slug.to_s
    @banner_image = criteria[:banner_image]
    @criteria = criteria
    @hidden_filters = criteria[:hidden_filters] || []
  end

  def count
    @count ||= Rails.cache.fetch(
      cache_key,
      # Introduce a bit of randomness into cache expiry to avoid cache stampedes where one request
      # will cause most or all counts to be refreshed
      expires_in: COUNT_CACHE_DURATION + rand(COUNT_CACHE_VARIATION_SECONDS).seconds,
    ) do
      fail_safe(0) { Search::VacancySearch.new(criteria).total_count }
    end
  end

  def name
    I18n.t(:name, **translation_args)
  end

  def heading
    I18n.t(:heading, **translation_args)
  end

  def meta_description
    I18n.t(:meta_description, **translation_args)
  end

  def title
    I18n.t(:title, **translation_args)
  end

  def banner_title
    I18n.t(:banner_title, **translation_args)
  end

  def v2?
    @banner_image.present?
  end

  private

  def cache_key
    [:landing_page_count, slug]
  end

  def translation_args
    count_html = "<span class=\"govuk-!-font-weight-bold\">#{count}</span>"
    {
      scope: [:landing_pages, slug],
      count: count_html,
    }
  end
end
