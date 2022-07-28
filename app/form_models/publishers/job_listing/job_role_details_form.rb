class Publishers::JobListing::JobRoleDetailsForm < Publishers::JobListing::VacancyForm
  validates :ect_status, inclusion: { in: Vacancy.ect_statuses.keys }

  def self.fields
    %i[ect_status]
  end
  attr_accessor(*fields)
end
