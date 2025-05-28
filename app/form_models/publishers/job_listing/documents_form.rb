class Publishers::JobListing::DocumentsForm < Publishers::JobListing::VacancyForm
  validates :supporting_documents, presence: true, if: -> { vacancy.include_additional_documents }

  attr_accessor :supporting_documents

  def self.fields
    [:supporting_documents]
  end

  def params_to_save
    { completed_steps: params[:completed_steps] }
  end
end
