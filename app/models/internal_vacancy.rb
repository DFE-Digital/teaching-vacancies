# frozen_string_literal: true

class InternalVacancy < Vacancy
  scope :draft, -> { where(draft: true) }
  scope :published, -> { where(draft: false) }
  scope :pending, -> { kept.where("publish_on > ?", Date.current) }

  scope :awaiting_feedback_recently_expired, -> { where(listed_elsewhere: nil, hired_status: nil).where(expires_at: 2.months.ago..) }

  validate :enable_job_applications_cannot_be_changed_once_listed, if: -> { persisted? && live? && enable_job_applications_changed? }
  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at, if: -> { listed_elsewhere_changed? && hired_status_changed? }

  private

  def on_expired_vacancy_feedback_submitted_update_stats_updated_at
    self.stats_updated_at = Time.current
  end

  def enable_job_applications_cannot_be_changed_once_listed
    errors.add(:enable_job_applications, :cannot_be_changed_once_listed)
  end
end
