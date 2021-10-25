class BaseForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  after_validation :send_errors_to_big_query

  def send_errors_to_big_query
    EventContext.trigger_event(:form_validated, formatted_errors) if errors.any?
  end

  private

  def formatted_errors
    errors.each_with_object({}) { |error, hash| hash[error.attribute] = error.type }
          .merge({ "form_name" => self.class.name.underscore })
  end
end
