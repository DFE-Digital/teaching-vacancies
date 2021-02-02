class Publishers::Vacancies::VacancyPublisherFeedbackForm
  include ActiveModel::Model

  attr_accessor :comment, :email, :feedback_type, :user_participation_response,
                :publisher_id, :vacancy_id

  validates :comment, presence: true, length: { maximum: 1200 }
  validates :email, presence: true, if: -> { user_participation_response == "interested" }
  validates :email, format: { with: Devise.email_regexp }, if: -> { email.present? }
  validates :user_participation_response, inclusion: { in: Feedback.user_participation_responses.keys }
  validates :publisher_id, presence: true
  validates :vacancy_id, presence: true
end
