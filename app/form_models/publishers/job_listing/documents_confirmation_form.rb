class Publishers::JobListing::DocumentsConfirmationForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  validates :upload_additional_document, inclusion: { in: [true, false] }

  def self.fields
    %i[upload_additional_document]
  end

  attribute :upload_additional_document, :boolean
end
