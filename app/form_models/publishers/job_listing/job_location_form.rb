class Publishers::JobListing::JobLocationForm < Publishers::JobListing::VacancyForm
  attr_accessor :organisation_ids, :phases

  validates :organisation_ids, presence: true

  def self.fields
    %i[organisation_ids phases]
  end

  def next_step
    :job_title
  end
end
