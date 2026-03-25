class JobRoleLocationLandingPage < LandingPage
  attr_reader :job_role, :location

  # Targeted roles and locations recommended by SEO agency
  TARGETED_JOB_ROLES = %w[sendco teaching_assistant assistant_headteacher head_of_year_or_phase].freeze
  TARGETED_LOCATIONS = %w[london manchester bristol birmingham nottingham].freeze
  TARGETED_PAGES = TARGETED_JOB_ROLES.product(TARGETED_LOCATIONS).freeze

  def self.exists?(job_role, location)
    normalized_job_role = job_role.downcase.tr("-", "_")
    TARGETED_PAGES.include?([normalized_job_role, location.downcase])
  end

  def self.[](job_role, location)
    raise "No such job role + location landing page: '#{job_role}' + '#{location}'" unless exists?(job_role, location)

    new(job_role.downcase.tr("-", "_"), location.downcase)
  end

  def initialize(job_role, location)
    @job_role = job_role
    @location = location
    super(slug, build_criteria)
  end

  def slug
    "#{job_role}-jobs-in-#{location}"
  end

  def location_name
    (MAPPED_LOCATIONS[location.tr("-", " ")] || location).titleize.gsub(/\bAnd\b/, "and")
  end

  def job_role_name
    I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}")
  end

  def title
    I18n.t("landing_pages._job_role_location.title", job_role: job_role_name, location: location_name)
  end

  private

  def build_criteria
    criteria = { location: location_name }

    if Vacancy::TEACHING_JOB_ROLES.include?(job_role)
      criteria[:teaching_job_roles] = [job_role]
    end

    if Vacancy::SUPPORT_JOB_ROLES.include?(job_role)
      criteria[:support_job_roles] = [job_role]
    end

    criteria
  end

  def cache_key
    [:job_role_location_landing_page_count, job_role, location]
  end

  def translation_args
    super.merge(
      scope: [:landing_pages, "_job_role_location"],
      job_role: job_role_name.downcase,
      location: location_name,
    )
  end
end
