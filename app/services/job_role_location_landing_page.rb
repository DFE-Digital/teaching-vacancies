class JobRoleLocationLandingPage < LandingPage
  attr_reader :job_role, :location

  def self.exists?(job_role, location)
    normalized_job_role = job_role.downcase.tr("-", "_")

    # Check if job role exists and location polygon exists
    Vacancy::JOB_ROLES.key?(normalized_job_role) && LocationPolygon.contain?(location.titleize)
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
