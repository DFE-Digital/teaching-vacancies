class Publishers::JobListing::ApplicationLinkForm < Publishers::JobListing::JobListingForm
  include ActiveModel::Attributes::Normalization

  attribute :application_link, :string
  normalizes :application_link, with: ->(application_link) { application_link.strip }

  validates :application_link, presence: true, url: { allow_blank: true }

  def self.fields
    %i[application_link]
  end
end
