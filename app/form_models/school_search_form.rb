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

  def to_h
    attrs = attributes.symbolize_keys
      .transform_values { |value| value.is_a?(Array) ? value.filter_map(&:presence).presence : value.presence }
      .compact

    if attrs.key?(:location)
      self.radius = Search::RadiusBuilder.new(attrs[:location], attrs[:radius]).radius.to_s
      attrs[:location] = [attrs[:location], radius]
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

  def education_phase_options
    School::READABLE_PHASE_MAPPINGS.values.uniq.compact.map { |i| [i, I18n.t(i, scope: "organisations.search.results.phases")] }
  end

  def key_stage_options
    School::PHASE_TO_KEY_STAGES_MAPPINGS.values.flatten.uniq.sort.map { |i| [i.to_s, I18n.t(i, scope: "organisations.search.results.key_stages")] }
  end

  def job_availability_options
    [true, false].map { |i| [i.to_s, I18n.t(i, scope: "organisations.filters.job_availability.options")] }
  end

  def assign_attributes(new_attributes)
    if new_attributes.respond_to?(:permitted?) && !new_attributes.permitted?
      new_attributes = new_attributes.permit(*self.class.strong_params_args)
    end

    super new_attributes
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
