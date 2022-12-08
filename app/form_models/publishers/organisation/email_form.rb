class Publishers::Organisation::EmailForm < BaseForm
  validates :email, presence: true, email_address: true
  attr_accessor :email
end
