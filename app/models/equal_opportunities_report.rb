class EqualOpportunitiesReport < ApplicationRecord
  belongs_to :vacancy

  validates :vacancy, uniqueness: true
end
