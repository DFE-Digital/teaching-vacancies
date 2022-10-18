module Resettable
  extend ActiveSupport::Concern

  included do
    before_save :reset_dependent_fields
  end

  def reset_dependent_fields
    reset_actual_salary
    reset_fixed_term_contract_duration
    reset_parental_leave_cover_contract_duration
    reset_keystages
    reset_subjects
    set_default_key_stage
    reset_ect_status
    reset_receive_applications
    reset_application_email
    reset_application_link
    reset_documents
    reset_personal_statement_guidance
    reset_school_visits_details
    reset_contact_number
    reset_safeguarding_information
    reset_further_details
  end

  def reset_actual_salary
    return unless working_patterns_changed? && working_patterns == ["full_time"]

    self.actual_salary = ""
  end

  def reset_fixed_term_contract_duration
    return unless contract_type_changed? && contract_type != "fixed_term"

    self.fixed_term_contract_duration = ""
  end

  def reset_parental_leave_cover_contract_duration
    return unless contract_type_changed? && contract_type != "parental_leave_cover"

    self.parental_leave_cover_contract_duration = ""
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
    return unless job_role_changed? && job_role != "teacher"

    self.ect_status = nil
  end

  def reset_receive_applications
    return unless enable_job_applications_changed? && enable_job_applications

    self.receive_applications = nil
  end

  def reset_application_email
    return unless receive_applications_changed? && receive_applications != "email"

    self.application_email = nil
  end

  def reset_application_link
    return unless receive_applications_changed? && receive_applications != "website"

    self.application_link = nil
  end

  def reset_documents
    return unless include_additional_documents_changed?

    supporting_documents.each(&:purge_later) unless include_additional_documents?
  end

  def reset_personal_statement_guidance
    return unless enable_job_applications_changed? && !enable_job_applications

    self.personal_statement_guidance = nil
  end

  def reset_school_visits_details
    return unless school_visits_changed? && !school_visits

    self.school_visits_details = nil
  end

  def reset_contact_number
    return unless contact_number_provided_changed? && !contact_number_provided

    self.contact_number = nil
  end

  def reset_safeguarding_information
    return unless safeguarding_information_provided_changed? && !safeguarding_information_provided

    self.safeguarding_information = nil
  end

  def reset_further_details
    return unless further_details_provided_changed? && !further_details_provided

    self.further_details = nil
  end
end
