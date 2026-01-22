class Publishers::JobListing::JobLocationForm < Publishers::JobListing::JobListingForm
  attr_accessor :organisation_ids, :phases

  validates :organisation_ids, presence: true

  def self.fields
    %i[organisation_ids phases]
  end
end
