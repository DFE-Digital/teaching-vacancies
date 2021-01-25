class Jobseekers::SignInForm
  include ActiveModel::Model

  attr_accessor :email, :password

  validates           :email, presence: true
  validates_format_of :email, with: Devise.email_regexp
  validates           :password, presence: true
end
