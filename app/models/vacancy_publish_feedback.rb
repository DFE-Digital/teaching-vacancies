class VacancyPublishFeedback < ApplicationRecord
  include FeedbackValidations

  enum user_participation_response: { interested: 0, not_interested: 1 }

  belongs_to :vacancy
  belongs_to :publisher
end
