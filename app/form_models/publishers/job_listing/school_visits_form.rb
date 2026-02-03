class Publishers::JobListing::SchoolVisitsForm < Publishers::JobListing::VacancyForm
  validates :school_visits, inclusion: { in: [true, false] }

  def self.fields
    %i[school_visits]
  end

  attribute :school_visits, :boolean
end
