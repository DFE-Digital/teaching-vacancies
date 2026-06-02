class SchoolSearchForm < OrganisationSearchForm
  attribute :education_phase, default: []
  attribute :key_stage, default: []
  attribute :organisation_types, default: []
  attribute :school_types, default: []

  def filters_list
    %i[
      education_phase
      key_stage
      job_availability
      organisation_types
      school_types
    ]
  end

  def education_phase_options
    School::READABLE_PHASE_MAPPINGS.values.uniq.compact.map { |i| [i, I18n.t(i, scope: "organisations.search.results.phases")] }
  end

  def key_stage_options
    School::PHASE_TO_KEY_STAGES_MAPPINGS.values.flatten.uniq.sort.map { |i| [i.to_s, I18n.t(i, scope: "organisations.search.results.key_stages")] }
  end

  def job_availability_options
    [["true", I18n.t("organisations.filters.job_availability.options.true")]]
  end

  def organisation_type_options
    [
      [I18n.t("helpers.label.publishers_job_listing_contract_information_form.organisation_type_options.academy"), "includes free schools"],
      [I18n.t("helpers.label.publishers_job_listing_contract_information_form.organisation_type_options.local_authority"), nil],
    ]
  end

  def school_type_options
    %w[faith_school special_school].map { |school_type| [school_type, I18n.t("organisations.filters.#{school_type}")] }
  end

  def assign_attributes(new_attributes)
    if new_attributes.respond_to?(:permitted?) && !new_attributes.permitted?
      new_attributes = new_attributes.permit(*self.class.strong_params_args)
    end

    super
  end

  def total_filters
    [
      job_availability,
      education_phase,
      key_stage,
      organisation_types,
      school_types,
    ].compact.sum(&:count)
  end

  class << self
    def strong_params_args
      return @strong_params_args if defined? @strong_params_args

      arrays, regular = new.attributes.partition { |_, v| v.is_a?(Array) }
      regular.map!(&:first).map!(&:to_sym)
      arrays = arrays.to_h.transform_values { [] }.transform_keys(&:to_sym)

      [*regular, arrays]
    end
  end
end
