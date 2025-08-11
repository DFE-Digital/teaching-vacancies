# frozen_string_literal: true

class PublishedVacancy < Vacancy
  # temporary solution - don't do this validation on manually published vacancies
  validate :no_duplicate_vacancy, if: -> { external? && job_title.present? && expires_at.present? && organisation_ids.present? }
  # this validates presence of certain fields for external vacancies
  validates_with ExternalVacancyValidator, if: :external?

  validate :enable_job_applications_cannot_be_changed_once_listed, if: -> { persisted? && listed? && enable_job_applications_changed? }

  validates :publish_on, presence: true

  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at, if: -> { listed_elsewhere_changed? && hired_status_changed? }

  def find_conflicting_vacancy
    find_external_reference_conflict_vacancy || find_duplicate_vacancy
  end

  # soft delete so that all the stats etc are kept even after the vacancy no longer exists
  def trash!
    return if discarded?

    supporting_documents.purge_later
    discard!
    remove_google_index
  end

  def draft?
    false
  end

  def expired?
    expires_at.past?
  end

  def published?
    true
  end

  def find_external_reference_conflict_vacancy
    return unless publisher_ats_api_client_id.present? && external_reference.present?

    self.class.kept.where(
      publisher_ats_api_client_id: publisher_ats_api_client_id,
      external_reference: external_reference,
    ).where.not(id: id).first
  end

  private

  def remove_google_index
    url = Rails.application.routes.url_helpers.job_url(self)
    RemoveGoogleIndexQueueJob.perform_later(url)
  end

  def on_expired_vacancy_feedback_submitted_update_stats_updated_at
    self.stats_updated_at = Time.current
  end

  def enable_job_applications_cannot_be_changed_once_listed
    errors.add(:enable_job_applications, :cannot_be_changed_once_listed)
  end

  def no_duplicate_vacancy
    if find_duplicate_vacancy
      errors.add(:base, "A vacancy with the same job title, expiry date, contract type, working_patterns, phases and salary already exists for this organisation.")
    end
  end

  def find_duplicate_vacancy
    self.class
        .kept
        .joins(:organisations)
        .where.not(id: id)
        .where(job_title: job_title, expires_at: expires_at, organisations: { id: organisation_ids }, contract_type: contract_type, salary: salary)
        .with_working_patterns(working_patterns)
        .with_phases(phases)
        .distinct
        .first
  end
end
