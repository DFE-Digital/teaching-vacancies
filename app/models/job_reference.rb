# frozen_string_literal: true

class JobReference < ApplicationRecord
  RATINGS_FIELDS_1 = %i[punctuality working_relationships customer_care adapt_to_change].freeze
  RATINGS_FIELDS_2 = %i[deal_with_conflict prioritise_workload team_working communication].freeze
  RATINGS_FIELDS_3 = %i[problem_solving general_attitude technical_competence leadership].freeze
  RATINGS_FIELDS = RATINGS_FIELDS_1 + RATINGS_FIELDS_2 + RATINGS_FIELDS_3

  RATING_OPTIONS = %w[outstanding good satisfactory poor na].freeze

  REFERENCE_INFO_FIELDS = %i[under_investigation warnings allegations not_fit_to_practice able_to_undertake_role].freeze

  REASON_DETAILS_FIELDS = %i[under_investigation_details warning_details unable_to_undertake_reason].freeze

  belongs_to :referee, foreign_key: :reference_id, inverse_of: :job_reference

  validates :reference_id, uniqueness: true

  has_encrypted :employment_start_date, type: :date
  has_encrypted :employment_end_date, type: :date

  RATINGS_FIELDS.each do |rating_field|
    has_encrypted rating_field
    validates rating_field, inclusion: { in: RATING_OPTIONS, allow_nil: true }
  end

  REASON_DETAILS_FIELDS.each do |field|
    has_encrypted field
  end

  REFERENCE_INFO_FIELDS.each do |field|
    has_encrypted field, type: :boolean
  end

  has_encrypted :how_do_you_know_the_candidate
  has_encrypted :reason_for_leaving
  has_encrypted :would_reemploy_current_reason
  has_encrypted :would_reemploy_any_reason

  def mark_as_received
    # invalidate token after reference is complete
    referee.reference_request.update!(status: :received, token: SecureRandom.uuid)
    Publishers::ReferenceReceivedNotifier.with(record: self).deliver
  end
end
