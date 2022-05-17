class Jobseekers::SearchForm
  include ActiveModel::Model

  attr_reader :keyword, :previous_keyword,
              :location, :radius,
              :organisation_slug,
              :transportation_type, :travel_time,
              :job_roles, :subjects, :phases, :working_patterns,
              :job_role_options, :ect_suitable_options, :send_responsible_options,
              :phase_options, :working_pattern_options,
              :filters_from_keyword, :total_filters, :sort

  def initialize(params = {})
    strip_trailing_whitespaces_from_params(params)
    @keyword = params[:keyword] || params[:subject]
    @previous_keyword = params[:previous_keyword]
    @landing_page = params[:landing_page]
    @location = params[:location]
    @job_roles = params[:job_roles] || params[:job_role] || []
    @subjects = params[:subjects] || []
    @phases = params[:phases] || []
    @working_patterns = params[:working_patterns] || []
    @organisation_slug = params[:organisation_slug] unless @keyword.present? || @location.present?
    @sort = Search::VacancySort.new(keyword: keyword).update(sort_by: params[:sort_by])
    @transportation_type = params[:transportation_type]
    @travel_time = params[:travel_time]

    set_filters_from_keyword
    unset_filters_from_previous_keyword

    set_radius(params[:radius])
    set_facet_options
    set_total_filters
  end

  def to_hash
    {
      keyword: @keyword,
      previous_keyword: @previous_keyword,
      organisation_slug: @organisation_slug,
      location: @location,
      radius: @radius,
      transportation_type: @transportation_type,
      travel_time: @travel_time,
      job_roles: @job_roles,
      subjects: @subjects,
      phases: @phases,
      working_patterns: @working_patterns,
    }.delete_if { |k, v| v.blank? || (k.eql?(:radius) && @location.blank?) }
  end

  private

  def strip_trailing_whitespaces_from_params(params)
    params.each_value { |value| value.strip! if value.respond_to?(:strip!) }
  end

  # Determines additional filters to apply if the user's keyword(s) match certain phrases
  # (to improve quality of results)
  def set_filters_from_keyword
    # Do not apply filters on landing pages, even if they have a keyword set (as landing pages
    # should always be 100% manually configured) OR if the user changes the filters *without*
    # changing their keywords, do not override their decision
    return if @keyword.blank? || @landing_page || @previous_keyword == @keyword

    @filters_from_keyword = Search::KeywordFilterGeneration::QueryParser.filters_from_query(@keyword)
    return unless @filters_from_keyword

    @subjects += filters_from_keyword["subjects"]
    @job_roles += filters_from_keyword["job_roles"]
    @phases += filters_from_keyword["phases"]
    @working_patterns += filters_from_keyword["working_patterns"]
  end

  def unset_filters_from_previous_keyword
    return unless @keyword.blank? && @previous_keyword.present?

    previous_filters = Search::KeywordFilterGeneration::QueryParser.filters_from_query(@previous_keyword)
    return unless previous_filters

    @subjects -= previous_filters["subjects"]
    @job_roles -= previous_filters["job_roles"]
    @phases -= previous_filters["phases"]
    @working_patterns -= previous_filters["working_patterns"]
  end

  def set_facet_options
    @job_role_options = Vacancy.main_job_role_options.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.main_job_role_options.#{option}")] }
    @phase_options = [%w[primary Primary], %w[middle Middle], %w[secondary Secondary], %w[16-19 16-19]]
    @ect_suitable_options = [["ect_suitable", I18n.t("jobs.filters.ect_suitable"), I18n.t("jobs.filters.ect_suitable_only")]]
    @send_responsible_options = [["send_responsible", I18n.t("jobs.filters.send_responsible"), I18n.t("jobs.filters.send_responsible_only")]]
    @working_pattern_options = Vacancy.working_patterns.keys.map do |option|
      [option, I18n.t("helpers.label.publishers_job_listing_working_patterns_form.working_patterns_options.#{option}")]
    end
  end

  def set_total_filters
    @total_filters = [@job_roles&.count, @subjects&.count, @phases&.count, @working_patterns&.count].compact.sum
  end

  def set_radius(radius_param)
    @radius = commute_area_search? ? 0 : Search::RadiusBuilder.new(location, radius_param).radius.to_s
  end

  def commute_area_search?
    transportation_type.present? && travel_time.present?
  end
end
