class Publishers::JobListing::EndListingForm < BaseForm
  attr_accessor :end_listing_reason, :candidate_hired_from

  validates :end_listing_reason, inclusion: { in: Vacancy.end_listing_reasons.keys }
  validates :candidate_hired_from, inclusion: { in: Vacancy.candidate_hired_froms.keys }, if: -> { end_listing_reason == "suitable_candidate_found" }
end
