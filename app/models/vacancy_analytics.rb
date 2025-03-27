class VacancyAnalytics < ApplicationRecord
  belongs_to :vacancy

  validates :referrer_url, presence: true
  validates :date, presence: true
  # Prevent duplicate entries for the same vacancy, referrer and date
  validates :referrer_url, uniqueness: { scope: %i[vacancy_id date] }
end
