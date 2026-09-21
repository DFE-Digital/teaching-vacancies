# This module is used to keep the vacancy/vacancy_template shape 'correct'
# in the light of various changes - so e.g. when the vacancy doesn't have benefits,
# then the 'details' field doesn't make sense.
# This was originally done in a before_save hook, but that it not ideal, as it is still
# possible to create an invalid object in memory, so some rules have been moved
# to attribute assignment overloads.
# These have not all been done because the array_enums do not support this
# (working_patterns, job_roles, key_stages)
# (array_enum is hand-rolled in this project)
# and the vacancy_template doesn't have all the fields e.g. application_link
#
# Refactoring of this is also hindered by it being called directly by the legacy
# vacancy import feature - so more progress could possibly be made once that feature has been removed.
#
# Ideally these 'shapes' would be validated, but it's quite difficult to do
# as e.g. hidden content behind de-selected radio buttons is still transmitted, so somnething simple
# like benefit_details is still on the form even when the content is invisible due to benefits - 'No'

module Resettable
  extend ActiveSupport::Concern

  included do
    # expired vacancies often have fields that no longer validate, so
    # performing this on a before_save hook (during backfills) can be problematic
    before_save :reset_dependent_fields, if: -> { resettable? }
  end

  def reset_dependent_fields
    reset_actual_salary
    reset_keystages
    reset_subjects
    set_default_key_stage
    reset_ect_status
    reset_application_email
    reset_application_form
    reset_application_link
    reset_documents
  end

  def reset_actual_salary
    return unless working_patterns_changed? && working_patterns == ["full_time"]

    self.actual_salary = ""
  end

  def contract_type=(value)
    self.fixed_term_contract_duration = "" if value != "fixed_term"
    super
  end

  def reset_keystages
    self.key_stages = [] unless allow_key_stages?
  end

  def reset_subjects
    self.subjects = [] unless allow_subjects?
  end

  def set_default_key_stage
    self.key_stages = key_stages_for_phases if key_stages_for_phases.one?
  end

  def reset_ect_status
    return unless job_roles_changed? && job_roles.exclude?("teacher")

    self.ect_status = nil
  end

  def enable_job_applications=(value)
    self[:receive_applications] = nil if value
    super
  end

  def reset_application_email
    return unless receive_applications_changed? && receive_applications != "email"

    self.application_email = nil
  end

  def reset_application_form
    return unless enable_job_applications_changed? || receive_applications_changed?

    application_form.purge_later if enable_job_applications || receive_applications == "website"
  end

  def reset_application_link
    return unless receive_applications_changed? && receive_applications != "website"

    self.application_link = nil
  end

  def reset_documents
    return unless include_additional_documents_changed?

    supporting_documents.each(&:purge_later) unless include_additional_documents?
  end

  def contact_number_provided=(value)
    self[:contact_number] = nil unless value
    super
  end

  def further_details_provided=(value)
    self[:further_details] = nil unless value
    super
  end

  def benefits=(value)
    self[:benefits_details] = nil unless value
    super
  end
end
