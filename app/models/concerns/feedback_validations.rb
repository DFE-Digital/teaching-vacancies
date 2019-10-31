module FeedbackValidations
  extend ActiveSupport::Concern

  EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i.freeze

  included do
    validates :comment, presence: { message: I18n.t('feedback.comment_errors.blank') }, length: \
      { maximum: 1200, message: I18n.t('feedback.comment_errors.over_max_length') }

    validates :user_participation_response, presence: \
      { message: I18n.t('general_feedback.user_participation_errors.blank') }

    validate :email_address_given?, if: :user_is_interested?
  end

  def email_address_given?
    return errors.add(:email, I18n.t('general_feedback.user_interested_email_errors.blank')) if email.blank?
    errors.add(:email, I18n.t('general_feedback.user_interested_email_errors.incorrect_format')) \
      unless email.match(EMAIL_REGEX)
  end

  def user_is_interested?
    user_participation_response == 'interested'
  end
end
