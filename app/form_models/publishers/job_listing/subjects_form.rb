class Publishers::JobListing::SubjectsForm < Publishers::JobListing::VacancyForm
  def self.fields
    %i[subjects]
  end
  attr_accessor(*fields)
end
