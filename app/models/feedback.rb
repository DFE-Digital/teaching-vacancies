class Feedback < ApplicationRecord
  belongs_to :vacancy
  validates :rating, presence: true

  scope :published_on, (->(date) { where('date(created_at) = ?', date) })
end
