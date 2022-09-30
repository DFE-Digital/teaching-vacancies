class Publishers::JobListing::SchoolVisitsForm < Publishers::JobListing::VacancyForm
  validates :school_visits, inclusion: { in: [true, false, "true", "false"] }
  validates :school_visits_details, presence: true, if: -> { vacancy&.school_visits_details.present? }

  def self.fields
    %i[school_visits_details school_visits]
  end
  attr_accessor(*fields)
end
