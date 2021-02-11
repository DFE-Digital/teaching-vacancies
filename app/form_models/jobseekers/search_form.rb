class Jobseekers::SearchForm
  include ActiveModel::Model

  attr_reader :keyword,
              :location, :radius,
              :job_roles, :phases, :working_patterns,
              :job_role_options, :phase_options, :working_pattern_options,
              :total_filters

  attr_accessor :jobs_sort

  def initialize(params = {})
    strip_trailing_whitespaces_from_params(params)
    @keyword = params[:keyword] || params[:subject]

    @location = params[:location]

    @radius = params[:radius] || 10
    @buffer_radius = params[:buffer_radius]

    @job_roles = params[:job_roles] || params[:job_role]
    @phases = params[:phases]
    @working_patterns = params[:working_patterns]

    @jobs_sort = params[:jobs_sort]

    set_facet_options
    set_total_filters
  end

  def to_hash
    {
      keyword: @keyword,
      location: @location,
      radius: @radius,
      buffer_radius: @buffer_radius,
      job_roles: @job_roles,
      phases: @phases,
      working_patterns: @working_patterns,
      jobs_sort: @jobs_sort,
    }.delete_if { |k, v| v.blank? || (k.eql?(:radius) && @location.blank?) }
  end

  private

  def strip_trailing_whitespaces_from_params(params)
    params.each_value { |value| value.strip! if value.respond_to?(:strip!) }
  end

  def set_facet_options
    @job_role_options = Vacancy.job_roles.keys.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_details_form.job_roles_options.#{option}")] }
    @phase_options = [%w[primary Primary], %w[middle Middle], %w[secondary Secondary], %w[16-19 16-19]]
    @working_pattern_options = Vacancy.working_patterns.keys.map do |option|
      [option, I18n.t("helpers.label.publishers_job_listing_job_details_form.working_patterns_options.#{option}")]
    end
  end

  def set_total_filters
    @total_filters = [@job_roles&.count, @phases&.count, @working_patterns&.count].reject(&:nil?).sum
  end
end
