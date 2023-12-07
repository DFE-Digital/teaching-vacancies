class Jobseekers::SearchForm
  include ActiveModel::Model

  attr_reader :ect_status_options,
              :ect_statuses,
              :filters_from_keyword,
              :job_role_options,
              :job_roles,
              :keyword,
              :location,
              :organisation_slug,
              :organisation_type_options,
              :organisation_types,
              :phase_options,
              :phases,
              :previous_keyword,
              :quick_apply,
              :quick_apply_options,
              :radius,
              :school_type_options,
              :school_types,
              :sort,
              :subjects,
              :total_filters,
              :visa_sponsorship_availability,
              :visa_sponsorship_availability_options,
              :working_pattern_options,
              :working_patterns

  def initialize(params = {})
    strip_trailing_whitespaces_from_params(params)
    set_filter_variables(params)
    @sort = Search::VacancySort.new(keyword: keyword, location: location).update(sort_by: params[:sort_by])
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
      location: @location,
      radius: @radius,
      organisation_slug: @organisation_slug,
      job_roles: @job_roles,
      ect_statuses: @ect_statuses,
      subjects: @subjects,
      phases: @phases,
      quick_apply: @quick_apply,
      working_patterns: @working_patterns,
      organisation_types: @organisation_types,
      school_types: @school_types,
      visa_sponsorship_availability: @visa_sponsorship_availability
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
    return if @keyword.blank? || @landing_page.present? || @previous_keyword == @keyword
    
    @filters_from_keyword = Search::KeywordFilterGeneration::QueryParser.filters_from_query(@keyword)
    return unless @filters_from_keyword

    @job_roles += filters_from_keyword["job_roles"]
    @ect_statuses += filters_from_keyword["ect_statuses"]
    @phases += filters_from_keyword["phases"]
    @working_patterns += filters_from_keyword["working_patterns"]
    @visa_sponsorship_availability += filters_from_keyword["visa_sponsorship_availability"]
  end

  def unset_filters_from_previous_keyword
    return unless @keyword.blank? && @previous_keyword.present?

    previous_filters = Search::KeywordFilterGeneration::QueryParser.filters_from_query(@previous_keyword)
    return unless previous_filters

    @job_roles -= previous_filters["job_roles"]
    @ect_statuses -= previous_filters["ect_statuses"]
    @phases -= previous_filters["phases"]
    @working_patterns -= previous_filters["working_patterns"]
    @visa_sponsorship_availability += filters_from_keyword["visa_sponsorship_availability"]
  end

  def set_facet_options
    @visa_sponsorship_availability_options = [["true", I18n.t("jobs.filters.visa_sponsorship_availability.option")]]
    @job_role_options = Vacancy.job_roles.keys.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_job_role_form.job_role_options.#{option}")] }
    @phase_options = Vacancy.phases.keys.map { |option| [option, I18n.t("helpers.label.publishers_job_listing_education_phases_form.phases_options.#{option}")] }
    @ect_status_options = [["ect_suitable", I18n.t("jobs.filters.ect_suitable")]]
    set_quick_apply_options
    @working_pattern_options = Vacancy.working_patterns.keys.map do |option|
      [option, I18n.t("helpers.label.publishers_job_listing_working_patterns_form.working_patterns_options.#{option}")]
    end
    set_organisation_type_options
    @school_type_options = %w[faith_school special_school].map { |school_type| [school_type, I18n.t("organisations.filters.#{school_type}")] }
  end

  def set_filter_variables(params)
    @keyword = params[:keyword] || params[:subject]
    @previous_keyword = params[:previous_keyword]
    @landing_page = params[:landing_page]
    @location = params[:location]
    @visa_sponsorship_availability = params[:visa_sponsorship_availability] || []
    @job_roles = params[:job_roles] || []
    @ect_statuses = params[:ect_statuses] || []
    @subjects = params[:subjects] || []
    @phases = params[:phases] || []
    @quick_apply = params[:quick_apply] || []
    @working_patterns = params[:working_patterns] || []
    @organisation_slug = params[:organisation_slug]
    @organisation_types = params[:organisation_types] || []
    @school_types = params[:school_types] || []
  end

  def set_total_filters
    @total_filters = [@visa_sponsorship_availability&.count, @job_roles&.count, @ect_statuses&.count, @subjects&.count, @phases&.count, @quick_apply&.count, @working_patterns&.count, @organisation_types&.count, @school_types&.count].compact.sum
  end

  def set_radius(radius_param)
    @radius = Search::RadiusBuilder.new(location, radius_param).radius.to_s
  end

  def set_organisation_type_options
    @organisation_type_options = [
      [I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.academy"), "includes free schools"],
      [I18n.t("helpers.label.publishers_job_listing_working_patterns_form.organisation_type_options.local_authority"), nil],
    ]
  end

  # rubocop:disable Style/OpenStructUse
  def set_quick_apply_options
    @quick_apply_options = [
      OpenStruct.new(
        value: "quick_apply",
        text: I18n.t("helpers.label.publishers_job_listing_applying_for_the_job_form.quick_apply"),
        hint: I18n.t("helpers.label.publishers_job_listing_applying_for_the_job_form.quick_apply_hint"),
      ),
    ]
  end
  # rubocop:enable Style/OpenStructUse
end
