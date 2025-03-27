class Publishers::JobListing::DocumentsForm < Publishers::JobListing::VacancyForm
  validates :supporting_documents, form_file: DOCUMENT_VALIDATION_OPTIONS
  validate :document_presence

  attr_accessor :supporting_documents

  def self.fields
    [:supporting_documents]
  end

  def params_to_save
    { completed_steps: params[:completed_steps] }
  end

  def next_step
    :exit
  end

  private

  def document_presence
    return unless vacancy.include_additional_documents
    return if supporting_documents.present?

    errors.add(:supporting_documents, :blank)
  end
end
