class VacancyAlgoliaSearchForm
  include ActiveModel::Model

  attr_reader :keyword,
              :location, :location_category, :radius,
              :job_roles, :phases, :working_patterns,
              :jobs_sort, :page,
              :job_role_options, :school_phase_options, :working_pattern_options,
              :total_filters

  def initialize(params = {})
    @keyword = params[:keyword]

    @location = params[:location] || params[:location_category]
    @location_category = params[:location_category]
    @radius = params[:radius] || 10

    @job_roles = params[:job_roles]
    @phases = params[:phases]
    @working_patterns = params[:working_patterns]

    @jobs_sort = params[:jobs_sort]
    @page = params[:page]

    set_facet_options
    set_total_filters
  end

  def to_hash
    {
      keyword: @keyword,
      location: @location,
      location_category: @location_category,
      radius: @radius,
      job_roles: @job_roles,
      phases: @phases,
      working_patterns: @working_patterns,
      jobs_sort: @jobs_sort,
      page: @page
    }.delete_if { |k, v| v.blank? || (k.eql?(:radius) && @location.blank?) }
  end

  private

  def set_facet_options
    @job_role_options = Vacancy.job_roles.keys.map { |option| [option, I18n.t("jobs.job_role_options.#{option}")] }
    @school_phase_options = School.phases.keys.map { |option| [option, I18n.t("jobs.school_phase_options.#{option}")] }
    @working_pattern_options = Vacancy.working_patterns.keys.map do |option|
      [option, I18n.t("jobs.working_pattern_options.#{option}")]
    end
  end

  def set_total_filters
    @total_filters = [@job_roles&.count, @phases&.count, @working_patterns&.count].reject(&:nil?).inject(0, :+)
  end
end
