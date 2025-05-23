class SchoolSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name
  attribute :location
  attribute :radius, :integer, default: 0
  attribute :education_phase, default: []
  attribute :key_stage, default: []
  attribute :special_school, default: []
  attribute :job_availability, default: []
  attribute :organisation_types, default: []
  attribute :school_types, default: []

  def to_h
    attrs = attributes.symbolize_keys
      .transform_values { |value| value.is_a?(Array) ? value.filter_map(&:presence).presence : value.presence }
      .compact

    if attrs.key?(:location)
      self.radius = Search::RadiusBuilder.new(attrs[:location], attrs[:radius]).radius.to_s
      attrs[:radius] = radius
    else
      attrs.delete(:radius)
    end

    if attrs[:job_availability]&.one?
      attrs[:job_availability] = attrs[:job_availability].first == "true" ? ["true"] : ["false"]
    else
      attrs.delete(:job_availability)
    end

    attrs
  end

  def filters_list
    %i[
      education_phase
      key_stage
      special_school
      job_availability
      organisation_types
      school_types
    ]
  end

  def filters
    to_h.delete_if { |k, _| filters_list.exclude?(k) }
  end

  def special_school_options
    [["1", I18n.t("organisations.filters.special_school")]]
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
      education_phase&.count,
      key_stage&.count,
      special_school&.count,
      job_availability&.count,
      organisation_types&.count,
      school_types&.count,
    ].compact.sum
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
