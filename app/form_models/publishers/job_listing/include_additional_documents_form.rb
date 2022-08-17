class Publishers::JobListing::IncludeAdditionalDocumentsForm < Publishers::JobListing::VacancyForm
  validates :include_additional_documents, inclusion: { in: [true, false, "true", "false"] }

  def self.fields
    %i[include_additional_documents]
  end
  attr_accessor(*fields)
end
