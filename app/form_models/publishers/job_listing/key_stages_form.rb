class Publishers::JobListing::KeyStagesForm < Publishers::JobListing::VacancyForm
  FIELDS = %i[key_stages].freeze

  class << self
    def fields
      { key_stages: [] }
    end

    def field_list
      %i[key_stages]
    end
  end
  attr_accessor(*FIELDS)
end
