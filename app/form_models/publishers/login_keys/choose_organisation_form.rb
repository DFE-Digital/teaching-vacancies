class Publishers::LoginKeys::ChooseOrganisationForm < BaseForm
  include ActiveModel::Model

  attr_accessor :organisation

  validates :organisation, presence: true
end
