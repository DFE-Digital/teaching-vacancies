class Publishers::OrganisationForm < BaseForm
  attr_accessor :description, :url_override

  validates :url_override, url: { allow_blank: true }
end
