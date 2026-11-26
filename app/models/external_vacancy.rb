# frozen_string_literal: true

class ExternalVacancy < Vacancy
  validates_with ExternalVacancyValidator

  def find_conflicting_vacancy
    find_external_reference_conflict_vacancy || find_duplicate_external_vacancy
  end

  def find_external_reference_conflict_vacancy
    return unless publisher_ats_api_client_id.present? && external_reference.present?

    Vacancy.kept.where(
      publisher_ats_api_client_id: publisher_ats_api_client_id,
      external_reference: external_reference,
    ).where.not(id: id).first
  end

  # rubocop:disable Metrics/AbcSize
  def find_duplicate_external_vacancy
    return unless external? && job_title.present? && expires_at.present? && organisation_ids.present? &&
      contract_type.present? && salary.present? && working_patterns.present? && phases.present?

    Vacancy
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
end
