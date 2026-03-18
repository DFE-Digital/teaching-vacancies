class Publishers::JobListing::SubjectsForm < Publishers::JobListing::JobListingForm
  FIELDS = %i[subjects].freeze

  class << self
    # rubocop:disable Lint/UnusedMethodArgument
    def load_from_model(vacancy, current_publisher:)
      new(vacancy.slice(*FIELDS))
    end
    # rubocop:enable Lint/UnusedMethodArgument

    def fields
      { subjects: [] }
    end
  end
  attr_accessor(*FIELDS)

  def params_to_save
    { subjects: subjects }
  end
end
