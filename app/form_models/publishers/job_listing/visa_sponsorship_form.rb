class Publishers::JobListing::VisaSponsorshipForm < Publishers::JobListing::JobListingForm
  validates :visa_sponsorship_available, inclusion: { in: [true, false] }

  def self.fields
    %i[visa_sponsorship_available]
  end
  attribute :visa_sponsorship_available, :boolean
end
