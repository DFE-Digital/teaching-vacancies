class VacancyAlgoliaSearchForm
  include ActiveModel::Model

  attr_reader :keyword,
              :location, :location_category, :radius,
              :job_roles, :phases, :working_patterns,
              :jobs_sort, :page,
              :job_role_options, :phase_options, :working_pattern_options,
              :total_filters

  def initialize(params = {})
    @keyword = params[:keyword].strip!

    @location = params[:location].strip! || params[:location_category].strip!
    @location_category = params[:location_category].strip!
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
      page: @page,
    }.delete_if { |k, v| v.blank? || (k.eql?(:radius) && @location.blank?) }
  end

private

  def set_facet_options
    @job_role_options = Vacancy.job_roles.keys.map { |option| [option, I18n.t("helpers.label.job_details_form.job_roles_options.#{option}")] }
    @phase_options = [%w[primary Primary], %w[middle Middle], %w[secondary Secondary], %w[16-19 16-19]]
    @working_pattern_options = Vacancy.working_patterns.keys.map do |option|
      [option, I18n.t("helpers.label.job_details_form.working_patterns_options.#{option}")]
    end
  end

  def set_total_filters
    @total_filters = [@job_roles&.count, @phases&.count, @working_patterns&.count].reject(&:nil?).sum
  end
end
