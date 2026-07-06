class Publishers::JobListing::ConfirmJobAddressForm < Publishers::JobListing::JobListingForm
  attr_accessor :job_address_line1, :job_address_line2, :job_address_town, :job_address_county, :job_address_postcode

  validates :job_address_line1, presence: true, if: :any_address_field_present?
  validates :job_address_town, presence: true, if: :any_address_field_present?
  validates :job_address_postcode, presence: true, if: :any_address_field_present?

  def self.fields
    %i[job_address_line1 job_address_line2 job_address_town job_address_county job_address_postcode]
  end

  private

  def any_address_field_present?
    [job_address_line1, job_address_line2, job_address_town, job_address_county, job_address_postcode].any?(&:present?)
  end
end
