class Publishers::VacancySort < RecordSort
  VALID_VACANCY_TYPES = %w[published pending draft expired awaiting_feedback].freeze

  def initialize(organisation, vacancy_type)
    @organisation = organisation
    @vacancy_type = VALID_VACANCY_TYPES.include?(vacancy_type) ? vacancy_type : "published"
    @column = base_options.first.column
    @order = base_options.first.order
  end

  def options
    base_options.tap do |options|
      options << readable_job_location_option if @organisation.is_a?(SchoolGroup)
    end
  end

  private

  def base_options
    case @vacancy_type
    when "published"
      [
        SortOption.new("expires_on", "asc", I18n.t("jobs.sort_by.expires_on.ascending")),
        SortOption.new("job_title", "asc", I18n.t("jobs.sort_by.job_title.ascending")),
      ]
    when "pending"
      [
        SortOption.new("publish_on", "desc", I18n.t("jobs.sort_by.published_date.descending")),
        SortOption.new("expires_on", "asc", I18n.t("jobs.sort_by.expires_on.ascending")),
        SortOption.new("job_title", "asc", I18n.t("jobs.sort_by.job_title.ascending")),
      ]
    when "draft"
      [
        SortOption.new("created_at", "desc", I18n.t("jobs.sort_by.created_at.descending.vacancy")),
        SortOption.new("updated_at", "desc", I18n.t("jobs.sort_by.updated_at.descending")),
        SortOption.new("job_title", "asc", I18n.t("jobs.sort_by.job_title.ascending")),
      ]
    when "expired", "awaiting_feedback"
      [
        SortOption.new("expires_on", "desc", I18n.t("jobs.sort_by.expires_on.descending")),
        SortOption.new("job_title", "asc", I18n.t("jobs.sort_by.job_title.ascending")),
      ]
    end
  end

  def readable_job_location_option
    SortOption.new("readable_job_location", "asc", I18n.t("jobs.sort_by.location.ascending"))
  end
end
