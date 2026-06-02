# frozen_string_literal: true

class OrganisationSearchForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name
  attribute :location
  attribute :radius, :integer, default: 0
  attribute :job_availability, default: []

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

    # :nocov:
    if attrs[:job_availability]&.one?
      attrs[:job_availability] = attrs[:job_availability].first == "true" ? %w[true] : %w[false]
    else
      attrs.delete(:job_availability)
    end
    # :nocov:

    attrs
  end

  def filters
    to_h.delete_if { |k, _| filters_list.exclude?(k) }
  end
end
