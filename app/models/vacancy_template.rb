# frozen_string_literal: true

class VacancyTemplate < ApplicationRecord
  extend ArrayEnum
  include VacancyChecks

  array_enum job_roles: Vacancy::JOB_ROLES
  enum :ect_status, Vacancy::ECT_STATUSES
  enum :contract_type, Vacancy::CONTRACT_TYPES
  array_enum key_stages: Vacancy::KEY_STAGES
  array_enum phases: Vacancy::PHASES
  array_enum working_patterns: Vacancy::WORKING_PATTERNS_ENUM

  # These are set when enable_job_applications is false.
  # 0 was for email applications (on vacancy, but removed 24/7/25)
  enum :receive_applications, { website: 1, uploaded_form: 2 }

  enum :religion_type, Vacancy::RELIGION_TYPES
end
