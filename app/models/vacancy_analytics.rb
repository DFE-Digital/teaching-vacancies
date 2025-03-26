class VacancyAnalytics < ApplicationRecord
  belongs_to :vacancy

  validates :referrer_url, presence: true
  validates :date, presence: true

  # Prevent duplicate entries for the same vacancy, referrer and date
  validates :referrer_url, uniqueness: { scope: %i[vacancy_id date] }

  scope :for_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :by_referrer, ->(referrer) { where(referrer_url: referrer) }

  def track_vacancy_view(referrer)
    # Track asynchronously to not impact response time
    TrackVacancyViewJob.perform_later(
      vacancy_id: id,
      referrer_url: referrer,
    )
  end
end