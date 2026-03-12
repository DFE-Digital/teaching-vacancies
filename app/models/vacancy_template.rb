# frozen_string_literal: true

class VacancyTemplate < ApplicationRecord
  extend ArrayEnum
  include VacancyChecks

  array_enum job_roles: Vacancy::JOB_ROLES
  enum :ect_status, Vacancy::ECT_STATUSES
  enum :contract_type, Vacancy::CONTRACT_TYPES
end
