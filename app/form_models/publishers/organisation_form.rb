class Publishers::OrganisationForm
  include ActiveModel::Model

  attr_accessor :description, :website

  validates :website, url: { allow_blank: true }
end
