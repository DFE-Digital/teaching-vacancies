class JobseekerSignInForm
  include ActiveModel::Model

  AUTHENTICATION_FAILURE_MESSAGES = [
    I18n.t("devise.failure.invalid"),
    I18n.t("devise.failure.not_found_in_database"),
    I18n.t("devise.failure.locked"),
    I18n.t("devise.failure.last_attempt"),
  ].freeze

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
