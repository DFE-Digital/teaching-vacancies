class Publishers::OrganisationForm < BaseForm
  attr_accessor :description, :website

  validates :website, url: { allow_blank: true }
end
