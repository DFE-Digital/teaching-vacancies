class Feedback < ApplicationRecord
  belongs_to :vacancy
  validates :rating, presence: true
end
