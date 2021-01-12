class Publishers::VacancySort < RecordSort
  VALID_VACANCY_TYPES = %w[published pending draft expired awaiting_feedback].freeze

  def initialize(organisation, vacancy_type)
    @organisation = organisation
    @vacancy_type = VALID_VACANCY_TYPES.include?(vacancy_type) ? vacancy_type : "published"
    @column = send("#{@vacancy_type}_options").first.column
    @order = send("#{@vacancy_type}_options").first.order
  end

  def options
    send("#{@vacancy_type}_options").tap do |options|
      options << readable_job_location_option if @organisation.is_a?(SchoolGroup)
    end
  end

private

  def published_options
    [
      SortOption.new("expires_on", "asc", I18n.t("jobs.sort_by.expires_on.ascending")),
      SortOption.new("job_title", "asc", I18n.t("jobs.sort_by.job_title.ascending")),
    ]
  end

  def pending_options
    [
      SortOption.new("publish_on", "desc", I18n.t("jobs.sort_by.published_date.descending")),
      SortOption.new("expires_on", "asc", I18n.t("jobs.sort_by.expires_on.ascending")),
      SortOption.new("job_title", "asc", I18n.t("jobs.sort_by.job_title.ascending")),
    ]
  end

  def draft_options
    [
      SortOption.new("created_at", "desc", I18n.t("jobs.sort_by.created_at.descending.vacancy")),
      SortOption.new("updated_at", "desc", I18n.t("jobs.sort_by.updated_at.descending")),
      SortOption.new("job_title", "asc", I18n.t("jobs.sort_by.job_title.ascending")),
    ]
  end

  def expired_options
    [
      SortOption.new("expires_on", "desc", I18n.t("jobs.sort_by.expires_on.descending")),
      SortOption.new("job_title", "asc", I18n.t("jobs.sort_by.job_title.ascending")),
    ]
  end

  def awaiting_feedback_options
    [
      SortOption.new("expires_on", "desc", I18n.t("jobs.sort_by.expires_on.descending")),
      SortOption.new("job_title", "asc", I18n.t("jobs.sort_by.job_title.ascending")),
    ]
  end

  def readable_job_location_option
    SortOption.new("readable_job_location", "asc", I18n.t("jobs.sort_by.location.ascending"))
  end

  def valid_sort_columns
    %w[job_title
       readable_job_location
       expires_on
       publish_on
       created_at
       updated_at
       total_pageviews].freeze
  end
end
