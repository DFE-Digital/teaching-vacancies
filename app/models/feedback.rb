class Feedback < ApplicationRecord
  belongs_to :vacancy
  belongs_to :user

  validates :rating, presence: true

  scope :published_on, (->(date) { where('date(created_at) = ?', date) })

  def to_row
    [
      created_at.iso8601.to_s,
      user.oid,
      vacancy.id,
      vacancy.school.urn,
      rating,
      comment
    ]
  end
end
