class Publishers::JobListing::SchoolVisitsForm < Publishers::JobListing::VacancyForm
  validates :school_visits, inclusion: { in: [true, false, "true", "false"] }

  def self.fields
    %i[school_visits]
  end
  attr_accessor(*fields)
end
