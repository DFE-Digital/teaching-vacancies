class BaseForm
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  after_validation :send_errors_to_big_query

  def send_errors_to_big_query
    EventContext.trigger_event(:form_validated, data) if errors.any?
  end

  private

  def data
    errors.each_with_object({ "form_name" => self.class.name.underscore }) { |error, data| data[error.attribute] = error.type }
  end
end
