class Publishers::JobListing::EducationPhasesForm < Publishers::JobListing::JobListingForm
  validates :phases, presence: true, inclusion: { in: Vacancy.phases.keys }

  FIELDS = %i[phases].freeze

  class << self
    # rubocop:disable Lint/UnusedMethodArgument
    def load_from_model(vacancy, current_publisher:)
      new(vacancy.slice(*FIELDS))
    end
    # rubocop:enable Lint/UnusedMethodArgument

    def fields
      { phases: [] }
    end
  end

  def params_to_save
    { phases: phases }
  end

  attr_accessor(*FIELDS)
end
