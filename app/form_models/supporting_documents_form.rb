class SupportingDocumentsForm < VacancyForm
  validates :supporting_documents, inclusion: { in: %w[yes no] }
end
