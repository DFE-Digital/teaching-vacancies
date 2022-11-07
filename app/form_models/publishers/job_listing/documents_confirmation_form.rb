class Publishers::JobListing::DocumentsConfirmationForm < Publishers::JobListing::VacancyForm
  validates :upload_additional_document, inclusion: { in: [true, false, "true", "false"] }

  def self.fields
    %i[upload_additional_document]
  end
  attr_accessor(*fields)
end
