class Jobseekers::SignInForm
  include ActiveModel::Model

  attr_accessor :email, :password

  validates :email, presence: true, email_address: true
  validates :password, presence: true
end
