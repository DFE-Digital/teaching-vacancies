class Publishers::JobListing::ConfirmJobAddressForm < Publishers::JobListing::JobListingForm
  attr_accessor :job_address_line1, :job_address_line2, :job_address_town, :job_address_county, :job_address_postcode

  def self.fields
    %i[job_address_line1 job_address_line2 job_address_town job_address_county job_address_postcode]
  end
end
