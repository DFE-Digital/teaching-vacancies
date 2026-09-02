module Resettable
  extend ActiveSupport::Concern

  included do
    # expired vacancies often have fields that no longer validate, so
    # performing this on a before_save hook (during backfills) can be problematic
    before_save :reset_dependent_fields, if: -> { resettable? }
  end

  def reset_dependent_fields
    set_default_key_stage
    reset_ect_status
    reset_application_form
    reset_documents
  end

  def set_default_key_stage
    self.key_stages = key_stages_for_phases if key_stages_for_phases.one?
  end

  def reset_ect_status
    return unless job_roles_changed? && job_roles.exclude?("teacher")

    self.ect_status = nil
  end

  def reset_application_form
    return unless enable_job_applications_changed? || receive_applications_changed?

    application_form.purge_later if enable_job_applications || receive_applications == "website"
  end

  def reset_documents
    return unless include_additional_documents_changed?

    supporting_documents.each(&:purge_later) unless include_additional_documents?
  end
end
