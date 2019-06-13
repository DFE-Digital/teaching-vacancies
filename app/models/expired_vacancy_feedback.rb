class ExpiredVacancyFeedback < ApplicationRecord
  belongs_to :vacancy
  belongs_to :user

  enum listed_elsewhere: %i[
    listed_paid
    listed_free
    listed_mix
    not_listed
    listed_dont_know
  ]
  enum hired_status: %i[
    hired_tvs
    hired_other_free
    hired_paid
    hired_free
    not_filled_ongoing
    not_filled_readvertised
    not_filled_not_looking
    hired_dont_know
  ]

  validates :listed_elsewhere, presence: true
  validates :hired_status, presence: true

  scope :published_on, (->(date) { where(created_at: date.all_day) })

  def to_row
    [
      Time.zone.now.to_s,
      user&.oid,
      vacancy.id,
      vacancy.school.urn,
      listed_elsewhere,
      hired_status,
      created_at.to_s
    ]
  end
end
