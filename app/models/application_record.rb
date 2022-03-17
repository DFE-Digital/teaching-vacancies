class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  before_save :strip_attributes

  after_create { EventContext.trigger_event(:entity_created, event_data) }
  after_update { EventContext.trigger_event(:entity_updated, event_data) unless saved_change_to_attribute?(:last_activity_at) }
  after_destroy { EventContext.trigger_event(:entity_destroyed, event_data) }

  DATA_ACCESS_PERIOD_FOR_PUBLISHERS = 1.year.freeze

  def attributes_except_ciphertext
    attributes.reject { |k, _v| k.include?("_ciphertext") }
  end

  private

  def event_data
    { "table_name" => self.class.table_name }.merge(anonymised_attributes)
  end

  def anonymised_attributes
    attributes_except_ciphertext.each_with_object({}) do |(key, value), anonymised|
      next unless export?(key)

      value = value.to_formatted_s(:iso8601) if value.respond_to?(:strftime)
      anonymised[key] = anonymise?(key) ? anonymise_value(value) : value
    end
  end

  def export?(attribute)
    Rails.configuration.analytics[self.class.table_name.to_sym]&.include?(attribute)
  end

  def anonymise?(attribute)
    Rails.configuration.analytics_pii[self.class.table_name.to_sym]&.include?(attribute)
  end

  def anonymise_value(value)
    case value
    when String
      StringAnonymiser.new(value).to_s
    when Array
      value.map { |string| StringAnonymiser.new(string).to_s }
    end
  end

  def strip_attributes
    attributes.each_value { |value| value.try(:strip!) unless value.frozen? }
  end
end
