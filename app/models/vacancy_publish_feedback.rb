class VacancyPublishFeedback < ApplicationRecord
  include FeedbackValidations

  enum user_participation_response: { interested: 0, not_interested: 1 }

  belongs_to :vacancy
  belongs_to :user

  scope :published_on, (->(date) { where(created_at: date.all_day) })

  def to_row
    [
      Time.zone.now.to_s,
      user&.oid,
      vacancy.id,
      vacancy.parent_organisation.urn,
      rating,
      comment,
      created_at.to_s,
      user_participation_response,
      email,
    ]
  end
end
