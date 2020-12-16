class AccountFeedback < ApplicationRecord
  enum rating: { highly_satisfied: 0, somewhat_satisfied: 1, neither: 2, somewhat_dissatisfied: 3, highly_dissatisfied: 4 }

  attr_accessor :back_link

  belongs_to :jobseeker

  validates :rating, inclusion: { in: ratings }
  validates :suggestions, length: { maximum: 1200 }, if: :suggestions?
end
