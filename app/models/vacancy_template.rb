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
end
