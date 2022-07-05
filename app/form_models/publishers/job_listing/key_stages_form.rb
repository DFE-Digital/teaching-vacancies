class Publishers::JobListing::KeyStagesForm < Publishers::JobListing::VacancyForm
  validates :key_stages, presence: true
  validates :key_stages, inclusion: { in: Vacancy.key_stages.keys }

  def self.fields
    %i[key_stages]
  end
  attr_accessor(*fields)
end
