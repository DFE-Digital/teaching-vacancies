class VacancyConflictAttempt < ApplicationRecord
  belongs_to :publisher_ats_api_client
  belongs_to :conflicting_vacancy, class_name: "Vacancy"

  validates :conflict_type, presence: true, inclusion: { in: %w[external_reference duplicate_content] }
  validates :attempts_count, presence: true, numericality: { greater_than: 0 }
  validates :first_attempted_at, presence: true
  validates :last_attempted_at, presence: true
  validates :conflicting_vacancy_id, uniqueness: { scope: :publisher_ats_api_client_id }

  scope :ordered_by_latest, -> { order(last_attempted_at: :desc) }
  scope :for_client, ->(client_id) { where(publisher_ats_api_client_id: client_id) }

  def self.track_attempt!(publisher_ats_api_client:, conflicting_vacancy:, conflict_type:)
    now = Time.current
    record = find_or_initialize_by(
      publisher_ats_api_client_id: publisher_ats_api_client.id,
      conflicting_vacancy_id: conflicting_vacancy.id,
    )

    record.assign_attributes(
      conflict_type: conflict_type,
      attempts_count: record.new_record? ? 1 : record.attempts_count + 1,
      first_attempted_at: record.new_record? ? now : record.first_attempted_at,
      last_attempted_at: now,
    )

    record.save!
    record
  end

  def conflicting_vacancy_publisher_type
    conflicting_vacancy.publisher_ats_api_client_id.present? ? "api_client" : "manual"
  end

  def conflicting_vacancy_publisher_name
    if conflicting_vacancy.publisher_ats_api_client_id.present?
      conflicting_vacancy.publisher_ats_api_client.name
    else
      conflicting_vacancy.organisations.first.name
    end
  end
end
