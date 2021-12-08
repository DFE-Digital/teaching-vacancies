module Resettable
  extend ActiveSupport::Concern

  included do
    before_save :reset_dependent_fields
  end

  def reset_dependent_fields
    reset_actual_salary
    reset_fixed_term_contract_duration
    reset_parental_leave_cover_contract_duration
    # Key stages and subjects are dependent on phase, so reset phase first
    reset_phase
    reset_key_stages
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

  def reset_phase
    self.phase = nil unless allow_phase_to_be_set?
  end

  def reset_key_stages
    self.key_stages = [] unless allow_key_stages?
  end

  def reset_subjects
    self.subjects = [] unless allow_subjects?
  end
end
