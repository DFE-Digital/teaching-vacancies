module Resettable
  extend ActiveSupport::Concern

  included do
    before_save :reset_dependent_fields
  end

  def reset_dependent_fields
    reset_actual_salary
    reset_fixed_term_contract_duration
    reset_parental_leave_cover_contract_duration
    reset_receive_applications
    reset_application_email
    reset_application_link
    set_default_key_stage
    reset_subjects
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

  def set_default_key_stage
    self.key_stages = key_stages_for_phases if key_stages_for_phases.one?
  end

  def reset_subjects
    self.subjects = [] unless allow_subjects?
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
end
