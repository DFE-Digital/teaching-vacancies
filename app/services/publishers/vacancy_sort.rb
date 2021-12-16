class Publishers::VacancySort < RecordSort
  VALID_VACANCY_TYPES = %w[published pending draft expired awaiting_feedback].freeze

  def initialize(organisation, vacancy_type)
    @organisation = organisation
    @vacancy_type = VALID_VACANCY_TYPES.include?(vacancy_type) ? vacancy_type : "published"
    super
  end

  def options
    base_options.tap do |options|
      options << readable_job_location_option if @organisation.school_group?
    end
  end

  private

  def base_options
    case @vacancy_type
    when "published"
      [soonest_closing_date_option, job_title_option]
    when "pending"
      [soonest_publication_date_option, soonest_closing_date_option, job_title_option]
    when "draft"
      [most_recent_draft_date_option, most_recent_update_option, job_title_option]
    when "expired", "awaiting_feedback"
      [most_recent_end_date_option, job_title_option]
    end
  end

  def job_title_option
    SortOption.new("job_title", I18n.t("jobs.sort_by.job_title.ascending"), "asc")
  end

  def most_recent_draft_date_option
    SortOption.new("created_at", I18n.t("jobs.sort_by.created_at.descending.vacancy"), "desc")
  end

  def most_recent_end_date_option
    SortOption.new("expires_at", I18n.t("jobs.sort_by.expires_at.descending.vacancy.publisher"), "desc")
  end

  def most_recent_update_option
    SortOption.new("updated_at", I18n.t("jobs.sort_by.updated_at.descending"), "desc")
  end

  def readable_job_location_option
    SortOption.new("readable_job_location", I18n.t("jobs.sort_by.location.ascending"), "asc")
  end

  def soonest_closing_date_option
    SortOption.new("expires_at", I18n.t("jobs.sort_by.expires_at.ascending.vacancy.publisher"), "asc")
  end

  def soonest_publication_date_option
    SortOption.new("publish_on", I18n.t("jobs.sort_by.published_date.descending"), "desc")
  end
end
