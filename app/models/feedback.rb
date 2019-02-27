class Feedback < ApplicationRecord
  belongs_to :vacancy
  belongs_to :user

  validates :rating, presence: true

  scope :published_on, (->(date) { where('date(created_at) = ?', date) })
end
