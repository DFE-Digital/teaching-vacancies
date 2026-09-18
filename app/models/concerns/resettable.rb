module Resettable
  extend ActiveSupport::Concern

  included do
    # expired vacancies often have fields that no longer validate, so
    # performing this on a before_save hook (during backfills) can be problematic
    before_save :reset_dependent_fields, if: -> { resettable? }
  end

  def reset_dependent_fields
    reset_actual_salary
    # reset_fixed_term_contract_duration
    reset_keystages
    reset_subjects
    set_default_key_stage

    reset_ect_status
    # reset_receive_applications
    reset_application_email
    reset_application_form
    reset_application_link
    reset_documents
    # reset_contact_number
    # reset_further_details
    # reset_benefits_details
  end

  def reset_actual_salary
    # return unless working_patterns_changed? && working_patterns == ["full_time"]
    #
    # self.actual_salary = ""
    if working_patterns_changed? && working_patterns == ["full_time"]
      self.actual_salary = ""
    end
  end
  # actual salary is only applicable for part_time or job_share positions (oops)
  # def working_patterns=(value)
  #   if value == %w[full_time]
  #     self.actual_salary = ""
  #   end
  #   super
  # end

  # fixed_term_contract_duration is only applicable for fixed_term contract types
  # def reset_fixed_term_contract_duration
  #   return unless contract_type_changed? && contract_type != "fixed_term"
  #
  #   self.fixed_term_contract_duration = ""
  # end
  def contract_type=(value)
    if value != "fixed_term"
      self.fixed_term_contract_duration = ""
    end
    super
  end

  ALLOWED_PHASES = %w[primary secondary through].freeze
  ALLOWED_ROLES = %w[teacher
                     headteacher
                     deputy_headteacher
                     assistant_headteacher
                     head_of_year_or_phase
                     head_of_department_or_curriculum
                     teaching_assistant].freeze

  def allow_key_stages?
    phases.intersect?(ALLOWED_PHASES) && job_roles.intersect?(ALLOWED_ROLES)
  end

  # key stages are only allowed for prim/sec/through and some teaching roles
  # def phases=(value)
  #   unless value.intersect?(ALLOWED_PHASES) && job_roles.intersect?(ALLOWED_ROLES)
  #     self.key_stages = []
  #   end
  #   super
  # end
  #
  # def job_roles=(value)
  #   unless phases.intersect?(ALLOWED_PHASES) && value.intersect?(ALLOWED_ROLES)
  #     self.key_stages = []
  #   end
  #   super
  # end

  def reset_keystages
    self.key_stages = [] unless allow_key_stages?
  end

  def allow_subjects?
    phases.any? { |phase| phase.in? %w[secondary sixth_form_or_college through] }
  end

  def reset_subjects
    self.subjects = [] unless allow_subjects?
  end

  def set_default_key_stage
    self.key_stages = key_stages_for_phases if key_stages_for_phases.one?
  end

  # def job_roles=(value)
  #   if value.exclude?("teacher")
  #     self.ect_status = nil
  #   end
  # end

  def reset_ect_status
    # return unless job_roles_changed? && job_roles.exclude?("teacher")
    #
    # self.ect_status = nil
    if job_roles_changed? && job_roles.exclude?("teacher")
      self.ect_status = nil
    end
  end

  # def reset_receive_applications
  #   return unless enable_job_applications_changed? && enable_job_applications
  #
  #   self.receive_applications = nil
  # end

  def enable_job_applications=(value)
    self[:receive_applications] = nil if value
    super
  end

  def reset_application_email
    return unless receive_applications_changed? && receive_applications != "email"

    self.application_email = nil
  end
  # def receive_applications=(value)
  #   self[:application_email] = nil if value != "email"
  #   self[:application_link] = nil if value != "website"
  #   super
  # end

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

  # def reset_contact_number
  #   return unless contact_number_provided_changed? && !contact_number_provided
  #
  #   self.contact_number = nil
  # end
  def contact_number_provided=(value)
    self.contact_number = nil unless value
    super
  end

  #
  # def reset_further_details
  #   return unless further_details_provided_changed? && !further_details_provided
  #
  #   self.further_details = nil
  # end
  def further_details_provided=(value)
    self.further_details = nil unless value
    super
  end

  #
  # def reset_benefits_details
  #   return unless benefits_changed? && !benefits
  #
  #   self.benefits_details = nil
  # end
  def benefits=(value)
    self.benefits_details = nil unless value
    super
  end
end
