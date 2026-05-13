class Search::SchoolSearch < Search::OrganisationSearch
  attr_reader :organisation_types, :school_types

  def initialize(search_criteria, scope:)
    super
    @organisation_types = search_criteria[:organisation_types]
    @school_types = search_criteria[:school_types]
  end

  def active_criteria?
    active_criteria.any?
  end

  def clear_filters_params
    active_criteria.merge({ education_phase: [], key_stage: [], job_availability: [], organisation_types: [], school_types: [] })
  end

  private

  def scope
    scope = super

    scope = scope.where(phase: education_phase) if education_phase
    scope = scope.where(phase: key_stage_phases) if key_stage_phases
    scope = apply_organisation_type_filter(scope)
    apply_school_type_filter(scope)
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

  def apply_organisation_type_filter(scope)
    return scope unless organisation_types.present?

    selected_school_types = []

    if organisation_types.include?("Academy")
      selected_school_types.push(School::ACADEMY_TYPE, School::FREE_SCHOOL_TYPE)
    end

    if organisation_types.include?("Local authority maintained schools")
      selected_school_types << School::LA_SCHOOL_TYPE
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
