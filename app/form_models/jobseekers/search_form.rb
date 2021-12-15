class Jobseekers::SearchForm
  include ActiveModel::Model

  attr_reader :keyword,
              :location, :radius,
              :job_roles, :phases, :working_patterns,
              :job_role_options, :ect_suitable_options, :send_responsible_options,
              :phase_options, :working_pattern_options,
              :total_filters, :sort

  def initialize(params = {})
    strip_trailing_whitespaces_from_params(params)
    @keyword = params[:keyword] || params[:subject]
    @location = params[:location]
    @job_roles = params[:job_roles] || params[:job_role] || []
    @phases = params[:phases]
    @working_patterns = params[:working_patterns]
    @sort = Search::VacancySort.new(keyword: keyword).update(sort_by: params[:sort_by])

    set_radius(params[:radius])
    set_facet_options
    set_total_filters
  end

  def to_hash
    {
      keyword: @keyword,
      location: @location,
      radius: @radius,
      job_roles: @job_roles,
      phases: @phases,
      working_patterns: @working_patterns,
    }.delete_if { |k, v| v.blank? || (k.eql?(:radius) && @location.blank?) }
  end

  private

  def strip_trailing_whitespaces_from_params(params)
    params.each_value { |value| value.strip! if value.respond_to?(:strip!) }
  end

  def set_facet_options
    @job_role_options = Vacancy.main_job_role_options.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.main_job_role_options.#{option}")] }
    @phase_options = [%w[primary Primary], %w[middle Middle], %w[secondary Secondary], %w[16-19 16-19]]
    @ect_suitable_options = [["ect_suitable", I18n.t("jobs.filters.ect_suitable_only"), I18n.t("jobs.filters.ect_suitable")]]
    @send_responsible_options = [["send_responsible", I18n.t("jobs.filters.send_responsible_only"), I18n.t("jobs.filters.send_responsible")]]
    @working_pattern_options = Vacancy.working_patterns.keys.map do |option|
      [option, I18n.t("helpers.label.publishers_job_listing_working_patterns_form.working_patterns_options.#{option}")]
    end
  end

  def set_total_filters
    @total_filters = [@job_roles&.count, @phases&.count, @working_patterns&.count].reject(&:nil?).sum
  end

  def set_radius(radius_param)
    @radius = Search::RadiusBuilder.new(location, radius_param).radius.to_s
  end
end
