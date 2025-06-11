# frozen_string_literal: true

class JobReference < ApplicationRecord
  RATINGS_FIELDS = %i[punctuality
                      working_relationships
                      customer_care
                      adapt_to_change
                      deal_with_conflict
                      prioritise_workload
                      team_working
                      communication
                      problem_solving
                      general_attitude
                      technical_competence
                      leadership].freeze

  RATING_OPTIONS = %w[outstanding good satisfactory poor na].freeze

  REFERENCE_INFO_FIELDS = %i[under_investigation warnings allegations not_fit_to_practice able_to_undertake_role].freeze

  belongs_to :referee, foreign_key: :reference_id, inverse_of: :job_reference

  validates :reference_id, uniqueness: true

  has_encrypted :employment_start_date, type: :date

  RATINGS_FIELDS.each do |rating_field|
    has_encrypted rating_field
    validates rating_field, inclusion: { in: RATING_OPTIONS, allow_nil: true }
  end

  REFERENCE_INFO_FIELDS.each do |field|
    has_encrypted field, type: :boolean
  end
end
