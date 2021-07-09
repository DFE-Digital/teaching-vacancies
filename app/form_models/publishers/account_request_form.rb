class Publishers::AccountRequestForm
  include ActiveModel::Model

  attr_accessor :full_name, :email, :organisation_name, :organisation_identifier

  validates :full_name, presence: true
  validates :email, presence: true
  validates :organisation_name, presence: true
  validates :email, format: { with: Devise.email_regexp }, if: -> { email.present? }
end
