# frozen_string_literal: true

class PublishedVacancy < Vacancy
  validate :enable_job_applications_cannot_be_changed_once_listed, if: -> { persisted? && listed? && enable_job_applications_changed? }

  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at, if: -> { listed_elsewhere_changed? && hired_status_changed? }

  # soft delete so that all the stats etc are kept even after the vacancy no longer exists
  def trash!
    return if discarded?

    supporting_documents.purge_later
    discard!
    remove_google_index
  end

  private

  def remove_google_index
    return if DisableExpensiveJobs.enabled?

    url = Rails.application.routes.url_helpers.job_url(self)
    RemoveGoogleIndexQueueJob.perform_later(url)
  end

  def on_expired_vacancy_feedback_submitted_update_stats_updated_at
    self.stats_updated_at = Time.current
  end

  def enable_job_applications_cannot_be_changed_once_listed
    errors.add(:enable_job_applications, :cannot_be_changed_once_listed)
  end
end
