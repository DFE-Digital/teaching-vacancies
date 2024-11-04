class Publishers::JobListing::VacancyForm < BaseForm
  attr_accessor :params, :vacancy, :completed_steps, :current_organisation

  DOCUMENT_VALIDATION_OPTIONS = {
    file_type: :document,
    content_types_allowed: %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document].freeze,
    file_size_limit: 10.megabytes,
    valid_file_types: %i[PDF DOC DOCX],
  }.freeze

  def initialize(params = {}, vacancy = nil, current_publisher = nil)
    @params = params
    @vacancy = vacancy
    @current_publisher = current_publisher

    super(params)
  end

  def params_to_save
    params.except(:current_organisation)
  end
end
