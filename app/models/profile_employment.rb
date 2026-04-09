class ProfileEmployment < ApplicationRecord
  belongs_to :jobseeker_profile

  has_encrypted :organisation, :job_title

  self.table_name = "employments"

  self.ignored_columns += %i[main_duties subjects reason_for_leaving]

  # This class represents 2 concerns - 'job' and 'break' (from employment)
  # which might have been better modelled as 2 different types
  enum :employment_type, { job: 0, break: 1 }

  validates :organisation, :job_title, presence: true, if: -> { job? }

  validates :started_on, date: { before: :today }, if: -> { job? }

  validates :ended_on, date: { before: :today, on_or_after: :started_on }, unless: -> { is_current_role? }, if: -> { job? }
  validates :ended_on, absence: true, if: -> { job? && is_current_role? }
end
