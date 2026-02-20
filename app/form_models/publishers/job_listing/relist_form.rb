class Publishers::JobListing::RelistForm < Publishers::JobListing::ImportantDatesForm
  attr_accessor :extension_reason, :other_extension_reason_details

  validates :extension_reason, inclusion: { in: Vacancy.extension_reasons.keys }

  def attributes_to_save
    {
      publish_on: publish_on,
      expires_at: expires_at,
      extension_reason: extension_reason,
      other_extension_reason_details: other_extension_reason_details,
    }
  end
end
