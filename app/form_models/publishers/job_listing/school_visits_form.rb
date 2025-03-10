class Publishers::JobListing::SchoolVisitsForm < Publishers::JobListing::VacancyForm
  include ActiveModel::Attributes

  validates :school_visits, inclusion: { in: [true, false] }

  def self.fields
    %i[school_visits_details school_visits]
  end
  attr_accessor(:school_visits_details)

  attribute :school_visits, :boolean
end
