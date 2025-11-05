# frozen_string_literal: true

class JobReference < ApplicationRecord
  RATINGS_FIELDS_1 = %i[punctuality working_relationships customer_care adapt_to_change].freeze
  RATINGS_FIELDS_2 = %i[deal_with_conflict prioritise_workload team_working communication].freeze
  RATINGS_FIELDS_3 = %i[problem_solving general_attitude technical_competence leadership].freeze
  RATINGS_FIELDS = RATINGS_FIELDS_1 + RATINGS_FIELDS_2 + RATINGS_FIELDS_3

  RATING_OPTIONS = %w[outstanding good satisfactory poor na].freeze

  REFERENCE_INFO_FIELDS = %i[under_investigation warnings allegations not_fit_to_practice able_to_undertake_role].freeze

  REASON_DETAILS_FIELDS = %i[under_investigation_details warning_details unable_to_undertake_reason].freeze

  belongs_to :reference_request, inverse_of: :job_reference

  validates :reference_request_id, uniqueness: true

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
    vacancy = reference_request.referee.job_application.vacancy
    registered_publisher_user = vacancy.organisation.publishers.find_by(email: contact_email)
    # invalidate token after reference is complete
    reference_request.update!(status: :received, token: SecureRandom.uuid)

    # cannot send a notification to a user that has not yet registered on our service so just send an email in that case.
    if registered_publisher_user
      Publishers::ReferenceReceivedNotifier.with(record: self).deliver
    else
      Publishers::CollectReferencesMailer.reference_received(reference_request).deliver_later
    end
  end
end
