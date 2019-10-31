module FeedbackValidations
  extend ActiveSupport::Concern

  included do
    validates :comment, presence: { message: I18n.t('feedback.comment_errors.blank') }, length: \
      { maximum: 1200, message: I18n.t('feedback.comment_errors.over_max_length') }

    validates :user_participation_response, presence: \
      { message: I18n.t('general_feedback.user_participation_errors.blank') }

    validates :email, email_address: { presence: true }, if: :user_is_interested?
  end

  def user_is_interested?
    user_participation_response == 'interested'
  end
end
