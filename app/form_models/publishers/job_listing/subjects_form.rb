class Publishers::JobListing::SubjectsForm < Publishers::JobListing::JobListingForm
  def self.fields
    %i[subjects]
  end
  attr_accessor(*fields)
end
