class Publishers::JobListing::VisaSponsorshipForm < Publishers::JobListing::VacancyForm
  validates :visa_sponsorship_available, inclusion: { in: [true, false, "true", "false"] }

  def self.fields
    %i[visa_sponsorship_available]
  end
  attr_accessor(*fields)
end
