class JobseekerSignInForm
  include ActiveModel::Model

  AUTHENTICATION_FAILURE_MESSAGES = %w[
    invalid not_found_in_database locked last_attempt
  ].map { |error| I18n.t("devise.failure.#{error}") }.freeze

  attr_reader :email, :password, :alert

  validates           :email, presence: true
  validates_format_of :email, with: Devise.email_regexp
  validates           :password, presence: true

  validate            :authentication

  def initialize(alert, params = {})
    @email = params[:email]
    @password = params[:password]
    @alert = alert
  end

  def authentication
    return unless AUTHENTICATION_FAILURE_MESSAGES.include?(alert) && errors.none?

    errors.add(:email, alert)
  end
end
