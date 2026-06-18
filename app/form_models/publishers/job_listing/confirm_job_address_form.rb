class Publishers::JobListing::ConfirmJobAddressForm < Publishers::JobListing::JobListingForm
  attr_accessor :job_address

  def self.fields
    %i[job_address]
  end
end
