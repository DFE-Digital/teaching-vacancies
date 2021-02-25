class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  after_create { EventContext.trigger_event(:entity_created, event_data) }
  after_update { EventContext.trigger_event(:entity_updated, event_data) unless saved_change_to_attribute?(:last_activity_at) }
  after_destroy { EventContext.trigger_event(:entity_destroyed, event_data) }

  private

  def event_data
    { table_name: self.class.table_name }.merge(anonymised_attributes)
  end

  def anonymised_attributes
    attributes.each_with_object({}) do |(key, value), anonymised|
      next unless export?(key)

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
end
