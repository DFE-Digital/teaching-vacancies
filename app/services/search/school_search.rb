class Search::SchoolSearch
  extend Forwardable

  def_delegators :location_search, :point_coordinates, :polygon

  attr_reader :search_criteria, :name, :location, :radius, :organisation_types, :school_types, :original_scope

  def initialize(search_criteria, scope:)
    @search_criteria = search_criteria
    @name = search_criteria[:name]
    @location = search_criteria[:location]
    @radius = search_criteria[:radius]
    @organisation_types = search_criteria[:organisation_types]
    @school_types = search_criteria[:school_types]
    @original_scope = scope.where(scope.where_values_hash)
    @scope = scope
  end

  def active_criteria
    search_criteria
      .reject { |k, v| v.blank? || (k == :radius && search_criteria[:location].blank?) }
  end

  def active_criteria?
    active_criteria.any?
  end

  def location_search
    @location_search ||= Search::LocationBuilder.new(search_criteria[:location], search_criteria[:radius])
  end

  def wider_search_suggestions
    @wider_search_suggestions ||= Search::WiderSuggestionsBuilder.call(self)
  end

  def organisations
    @organisations ||= scope
  end

  def total_count
    @total_count ||= organisations.count
  end

  def total_filters
    filter_counts = %i[education_phase key_stage special_school job_availability organisation_types school_types].map { |filter| search_criteria[filter]&.count || 0 }
    filter_counts.sum
  end

  def clear_filters_params
    active_criteria.merge({ education_phase: [], key_stage: [], job_availability: [], organisation_types: [], school_types: [] })
  end

  private

  def scope
    scope = @scope.all

    scope = scope.search_by_name(name) if name.present?
    scope = scope.search_by_location(location, radius, polygon:) if location
    scope = scope.where(phase: education_phase) if education_phase
    scope = scope.where(phase: key_stage_phases) if key_stage_phases
    scope = apply_organisation_type_filter(scope)
    scope = apply_school_type_filter(scope)
    apply_job_availability_filter(scope)
  end

  def marker_for_map(vacancy_id, organisation_id, geopoint)
    {
      id: vacancy_id,
      parent_id: organisation_id,
      geopoint: RGeo::GeoJSON.encode(geopoint)&.to_json,
    }
  end

  def education_phase
    return unless @search_criteria.key?(:education_phase)

    School::READABLE_PHASE_MAPPINGS.select { |_, v| @search_criteria[:education_phase].include? v }
                                   .map { |m| m.first.to_s }
  end

  def key_stage_phases
    return unless @search_criteria.key?(:key_stage)

    School::PHASE_TO_KEY_STAGES_MAPPINGS.select { |_, v| @search_criteria[:key_stage].intersect?(v.map(&:to_s)) }
                                        .map { |m| m.first.to_s }
  end

  def apply_job_availability_filter(scope)
    if @search_criteria.key?(:job_availability)
      scope.with_live_vacancies
    else
      scope
    end
  end

  def apply_organisation_type_filter(scope)
    return scope unless organisation_types.present?

    selected_school_types = []

    if organisation_types.include?("Academy")
      selected_school_types.push("Academy", "Academies", "Free schools", "Free school")
    end

    if organisation_types.include?("Local authority maintained schools")
      selected_school_types << "Local authority maintained schools"
    end

    scope.where(school_type: selected_school_types)
  end

  def apply_school_type_filter(scope)
    return scope unless school_types.present?

    if school_types.include?("special_school") && school_types.include?("faith_school")
      scope.where.not("gias_data ->> 'ReligiousCharacter (name)' IN (?)", Organisation::NON_FAITH_RELIGIOUS_CHARACTER_TYPES)
           .or(scope.where(detailed_school_type: Organisation::SPECIAL_SCHOOL_TYPES))
    elsif school_types.include?("special_school")
      scope.where(detailed_school_type: Organisation::SPECIAL_SCHOOL_TYPES)
    elsif school_types.include?("faith_school")
      scope.where.not("gias_data ->> 'ReligiousCharacter (name)' IN (?)", Organisation::NON_FAITH_RELIGIOUS_CHARACTER_TYPES)
    else
      scope
    end
  end
end
