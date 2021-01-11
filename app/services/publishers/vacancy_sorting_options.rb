class Publishers::VacancySortingOptions
  SortOption = Struct.new(:column, :display_name)

  include Enumerable

  def initialize(organisation, vacancy_type)
    @organisation = organisation
    @vacancy_type = vacancy_type
  end

  delegate :each, to: :options

  def options
    base_options.tap do |options|
      options << readable_job_location_option if @organisation.is_a?(SchoolGroup)
      options << publish_on_option if %i[pending draft].include?(@vacancy_type)
    end
  end

private

  def readable_job_location_option
    SortOption.new("readable_job_location", I18n.t("jobs.sort_by.location.ascending"))
  end

  def publish_on_option
    SortOption.new("publish_on", I18n.t("jobs.sort_by.published_date.ascending"))
  end

  def base_options
    [
      SortOption.new("expires_on", I18n.t("jobs.sort_by.expires_on.ascending")),
      SortOption.new("job_title", I18n.t("jobs.sort_by.job_title.ascending")),
    ]
  end
end
