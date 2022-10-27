class Publishers::JobListing::DocumentsForm < Publishers::JobListing::VacancyForm
  validates :upload_additional_document, inclusion: { in: [true, false, "true", "false"] }

  attr_accessor :upload_additional_document

  def self.fields
    []
  end

  def self.optional?
    true
  end

  def params_to_save
    {}
  end
end
