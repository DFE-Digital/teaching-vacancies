class BaseForm
  IMAGE_VALIDATION_OPTIONS = {
    file_type: :image,
    content_types_allowed: %w[image/jpeg image/png].freeze,
    file_size_limit: 5.megabytes,
    valid_file_types: %i[JPG JPEG PNG].freeze,
  }.freeze

  VALID_DOCUMENT_TYPES = %i[PDF DOC DOCX].freeze

  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  after_validation :send_errors_to_big_query

  def send_errors_to_big_query
    return if errors.none?

    EventContext.trigger_for_dfe_analytics(:form_validation_failed, event_data)
  end

  def number_of_words_exceeds_permitted_length?(number, attribute)
    number_of_words = remove_html_tags(attribute)&.split&.length

    number_of_words&.>(number)
  end

  private

  def event_data
    errors.each_with_object({ form_name: self.class.name.underscore }) { |error, data| data[error.attribute] = error.type }
  end

  def remove_html_tags(field)
    regex = /<("[^"]*"|'[^']*'|[^'">])*>/

    field&.gsub(regex, "")
  end
end
