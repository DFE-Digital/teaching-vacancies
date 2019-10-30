module FeedbackValidations
  extend ActiveSupport::Concern

  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze

  included do
    validates :comment, presence: { message: 'Enter your feedback' }, length: \
      { maximum: 1200, message: 'Feedback must not be more than 1,200 characters' }

    validates :user_participation_response, presence: \
      { message: "Please indicate if you'd like to participate in user research" }

    validate :email_address_given?, if: :user_is_interested?
  end

  def email_address_given?
    return errors.add(:email, 'Enter your email address') if email.blank?
    errors.add(:email, 'Enter an email address in the correct format, like name@example.com') \
      unless email.match(EMAIL_REGEX)
  end

  def user_is_interested?
    user_participation_response == 'interested'
  end
end
