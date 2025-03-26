class Publishers::JobListing::SubjectsForm < Publishers::JobListing::VacancyForm
  class << self
    def fields
      %i[subjects]
    end

    def permitted_params
      [ subjects: [] ]
    end
  end
  attr_accessor(*fields)
end
