class JobRoleLocationLandingPage
  attr_reader :job_role, :location

  # Targeted roles and locations recommended by SEO agency
  TARGETED_JOB_ROLES = %w[sendco teaching_assistant assistant_headteacher head_of_year_or_phase].freeze
  TARGETED_LOCATIONS = %w[london manchester bristol birmingham leeds sheffield manchester bradford liverpool bristol coventry leicester].freeze

  TARGETED_ROLE_PAGES = TARGETED_JOB_ROLES.product(TARGETED_LOCATIONS).freeze

  def self.exists?(job_role, location)
    normalized_job_role = job_role.downcase.tr("-", "_")
    TARGETED_ROLE_PAGES.include?([normalized_job_role, location.downcase])
  end

  def self.[](job_role, location)
    raise "No such job role + location landing page: '#{job_role}' + '#{location}'" unless exists?(job_role, location)

    new(job_role.downcase.tr("-", "_"), location.downcase)
  end

  def initialize(job_role, location)
    @job_role = job_role
    @location = location
    @location_name = CITIES_AND_REGIONS.fetch(location)
  end

  def job_role_name
    I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{job_role}")
  end

  def title
    I18n.t("landing_pages._job_role_location.title", job_role: job_role_name, location: @location_name)
  end

  def meta_description
    I18n.t("landing_pages._job_role_location.meta_description", job_role: job_role_name.downcase, location: @location_name)
  end

  def criteria
    { location: @location_name }.tap do |criteria|
      if Vacancy::TEACHING_JOB_ROLES.include?(job_role)
        criteria[:teaching_job_roles] = [job_role]
      end

      if Vacancy::SUPPORT_JOB_ROLES.include?(job_role)
        criteria[:support_job_roles] = [job_role]
      end
    end
  end

  def has_banner_image?
    false
  end

  def hidden_filters
    []
  end
end
