class Publishers::JobListing::JobLocationForm < Publishers::JobListing::VacancyForm
  attr_accessor :organisation_ids

  validates :organisation_ids, presence: true

  def self.fields
    %i[organisation_ids]
  end
end
