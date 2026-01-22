class Publishers::JobListing::IncludeAdditionalDocumentsForm < Publishers::JobListing::JobListingForm
  include ActiveModel::Attributes

  validates :include_additional_documents, inclusion: { in: [true, false] }

  def self.fields
    %i[include_additional_documents]
  end
  attribute :include_additional_documents, :boolean
end
