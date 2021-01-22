class Jobseekers::SignInForm
  include ActiveModel::Model

  attr_reader :email, :password

  validates           :email, presence: true
  validates_format_of :email, with: Devise.email_regexp
  validates           :password, presence: true

  def initialize(params = {})
    @email = params[:email]
    @password = params[:password]
  end
end
