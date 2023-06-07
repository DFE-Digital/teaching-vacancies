class Search::SchoolSearch
  extend Forwardable
  def_delegators :location_search, :point_coordinates

  attr_reader :search_criteria, :name, :location, :radius, :organisation_types

  def initialize(search_criteria, scope: Organisation.all)
    @search_criteria = search_criteria
    @name = search_criteria[:name]
    @location = search_criteria[:location]
    @radius = search_criteria[:radius]
    @organisation_types = search_criteria[:organisation_types]
    @scope = scope
  end

  def active_criteria
    search_criteria
      .reject { |k, v| v.blank? || (k == :radius && search_criteria[:location].blank?) }
  end

  def active_criteria?
    active_criteria.any?
  end

  def wider_search_suggestions
    return unless vacancies.empty? && search_criteria[:location].present?

    Search::WiderSuggestionsBuilder.new(search_criteria).suggestions
  end

  def organisations
    @organisations ||= scope
  end

  def total_count
    schools.count
  end

  def total_filters
    filter_counts = %i[education_phase key_stage special_school job_availability].map { |filter| search_criteria[filter]&.count || 0 }
    filter_counts.sum
  end

  def clear_filters_params
    active_criteria.merge({ education_phase: [], key_stage: [], special_school: [], job_availability: [], organisation_type: [] })
  end

  private

  def scope
    scope = @scope.all

    scope = scope.search_by_name(name) if name.present?
    scope = scope.search_by_location(*location) if location.present?
    scope = scope.where(phase: education_phase) if education_phase
    scope = scope.where(phase: key_stage_phases) if key_stage_phases
    scope = scope.where("organisations.gias_data->>'SpecialClasses (code)' = ?", "1") if special_school?
    scope = apply_organisation_type_filter(scope)
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

    School::READABLE_PHASE_MAPPINGS.select { |_, v| @search_criteria[:education_phase].include? v }.map(&:first).map(&:to_s)
  end

  def key_stage_phases
    return unless @search_criteria.key?(:key_stage)

    School::PHASE_TO_KEY_STAGES_MAPPINGS.select { |_, v| @search_criteria[:key_stage].intersect?(v.map(&:to_s)) }.map(&:first).map(&:to_s)
  end

  def special_school?
    return unless @search_criteria.key?(:special_school)

    @search_criteria[:special_school].first == "1"
  end

  def apply_job_availability_filter(scope)
    return scope unless @search_criteria.key?(:job_availability)

    vacancy_ids = Vacancy.live.select(:id)
    organisation_ids = OrganisationVacancy.where(vacancy_id: vacancy_ids).select(:organisation_id)

    if @search_criteria[:job_availability].first == "true"
      scope.where(id: organisation_ids)
    else
      scope.where.not(id: organisation_ids)
    end
  end

  def apply_organisation_type_filter(scope)
    return scope unless organisation_types.present?

    establishment_code_filter = []
    establishment_name_filter = []

    if organisation_types.include?("Academy")
      %w[10 11].each { |code| establishment_code_filter << code }
      ["Academies", "Free Schools"].each { |name| establishment_name_filter << name }
    end

    if organisation_types.include?("Local authority maintained schools")
      establishment_code_filter << "4"
      establishment_name_filter << "Local authority maintained schools"
    end

    scope.where("(gias_data->>'EstablishmentTypeGroup (code)' IN (?) OR gias_data->>'EstablishmentTypeGroup (name)' IN (?))", establishment_code_filter, establishment_name_filter)
  end
end
