class Publishers::JobListing::HowToReceiveApplicationsForm < Publishers::JobListing::VacancyForm
  validates :receive_applications, inclusion: { in: Vacancy.receive_applications.keys }

  def self.fields
    %i[receive_applications]
  end
  attr_accessor(*fields)
end
