# frozen_string_literal: true

class PublishedVacancy < Vacancy
  # Effectively we have two different types of published vacancies - external ones and internal ones.
  # These require seperate validation rules.
  #
  # Internal ones are built up over time by a user, so it is much harder to validate them at the model level.
  #
  # External ones are complete so they can be validated at this level (and have extra properties).
  # The ExternalVacancyValidator tries to do this, but it's really a separate type.
  validates_with ExternalVacancyValidator, if: :external?

  validate :enable_job_applications_cannot_be_changed_once_listed, if: -> { persisted? && live? && enable_job_applications_changed? }

  validates :publish_on, presence: true

  before_save :on_expired_vacancy_feedback_submitted_update_stats_updated_at, if: -> { listed_elsewhere_changed? && hired_status_changed? }

  scope :applicable, -> { where(expires_at: Time.current..) }
  scope :awaiting_feedback_recently_expired, -> { where(listed_elsewhere: nil, hired_status: nil).where(expires_at: 2.months.ago..) }
  scope :expired, -> { kept.where(expires_at: ...Time.current) }
  scope :expired_yesterday, -> { where("DATE(expires_at) = ?", 1.day.ago.to_date) }
  scope :expires_within_data_access_period, -> { where(expires_at: (Time.current - DATA_ACCESS_PERIOD_FOR_PUBLISHERS)..) }
  scope :listed, -> { kept.where(publish_on: ..Date.current) }
  scope :live, -> { listed.applicable }
  scope :pending, -> { kept.where("publish_on > ?", Date.current) }

  def find_conflicting_vacancy
    find_external_reference_conflict_vacancy || find_duplicate_external_vacancy
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
    expires_at&.past?
  end

  def published?
    discarded_at.nil?
  end

  def find_external_reference_conflict_vacancy
    return unless publisher_ats_api_client_id.present? && external_reference.present?

    self.class.kept.where(
      publisher_ats_api_client_id: publisher_ats_api_client_id,
      external_reference: external_reference,
    ).where.not(id: id).first
  end

  # rubocop:disable Metrics/AbcSize
  def find_duplicate_external_vacancy
    return unless external? && job_title.present? && expires_at.present? && organisation_ids.present? &&
      contract_type.present? && salary.present? && working_patterns.present? && phases.present?

    self.class
        .kept
        .joins(:organisations)
        .where.not(id: id)
        .where(job_title: job_title,
               expires_at: expires_at,
               organisations: { id: organisation_ids },
               contract_type: contract_type,
               salary: salary)
        .with_working_patterns(working_patterns)
        .with_phases(phases)
        .distinct
        .first
  end
  # rubocop:enable Metrics/AbcSize

  def find_publisher_by_contact_email
    Publisher.joins(:organisations)
             .where(organisations: { id: organisation_ids })
             .find_by(email: contact_email)
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
end
