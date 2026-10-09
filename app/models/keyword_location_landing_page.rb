class KeywordLocationLandingPage
  # Top 25 keywords with > 50 vacancies at time of publication
  TARGETED_KEYWORDS = %w[teacher
                         primary
                         teaching-assistant
                         science
                         maths
                         headteacher
                         ks2
                         early-years
                         ks1
                         mathematics
                         assistant
                         early-years-teacher
                         eyfs
                         pastoral
                         ta
                         head
                         primary-class-teacher
                         nursery
                         math-teacher
                         special-needs
                         secondary-teacher
                         special
                         class-teacher-primary
                         classroom-assistant].freeze
  TARGETED_KEYWORD_PAGES = TARGETED_KEYWORDS.product(JobRoleLocationLandingPage::TARGETED_LOCATIONS).freeze

  def self.exists?(keyword, location)
    normalized_keyword = keyword.tr(" ", "-")

    TARGETED_KEYWORD_PAGES.include?([normalized_keyword, location.downcase])
  end

  def initialize(keyword, location)
    @keyword = keyword.tr("-", " ")
    @location = location

    # None of our locations are unusual, so can just go straight to the mapping of downcase -> actual
    @location_name = CITIES_AND_REGIONS.fetch(location)
  end

  def criteria
    { keyword: @keyword, location: @location_name, radius: 25 }
  end

  def has_banner_image?
    false
  end

  def hidden_filters
    []
  end

  def title
    I18n.t("landing_pages._keyword_location.title", keyword: @keyword, location: @location)
  end

  def meta_description
    I18n.t("landing_pages._keyword_location.meta_description", keyword: @keyword, location: @location)
  end
end
