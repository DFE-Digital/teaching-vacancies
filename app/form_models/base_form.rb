class BaseForm
  attr_accessor :skip_after_validation_big_query_callback

  IMAGE_VALIDATION_OPTIONS = {
    file_type: :image,
    content_types_allowed: %w[image/jpeg image/png].freeze,
    file_size_limit: 5.megabytes,
    valid_file_types: %i[JPG JPEG PNG].freeze,
  }.freeze

  VALID_DOCUMENT_TYPES = %i[PDF DOC DOCX].freeze

  DOCUMENT_VALIDATION_OPTIONS = {
    file_type: :document,
    content_types_allowed: %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document].freeze,
    file_size_limit: 10.megabytes,
    valid_file_types: VALID_DOCUMENT_TYPES,
  }.freeze

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
    return if errors.none?

    EventContext.trigger_for_dfe_analytics(:form_validation_failed, event_data)
  end

  private

  def event_data
    errors.each_with_object({ form_name: self.class.name.underscore }) { |error, data| data[error.attribute] = error.type }
  end

  def number_of_words_exceeds_permitted_length?(number, attribute)
    number_of_words = remove_html_tags(attribute)&.split&.length

    number_of_words&.>(number)
  end

  def remove_html_tags(field)
    regex = /<("[^"]*"|'[^']*'|[^'">])*>/

    field&.gsub(regex, "")
  end
end
