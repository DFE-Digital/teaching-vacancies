class BaseForm
  attr_accessor :skip_after_validation_big_query_callback

  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  after_validation :send_errors_to_big_query, unless: :skip_after_validation_big_query_callback

  def self.target_name
    model_name.element.split("_")[0..-2].join("_").to_s
  end

  def self.optional?
    form_section = new
    form_section.skip_after_validation_big_query_callback = true
    form_section.valid?
  end

  def send_errors_to_big_query
    EventContext.trigger_event(:form_validation_failed, event_data) if errors.any?
  end

  private

  def event_data
    errors.each_with_object({ form_name: self.class.name.underscore }) { |error, data| data[error.attribute] = error.type }
  end
end
