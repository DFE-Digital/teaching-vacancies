class Employment < ApplicationRecord
  include ApplicationAndProfileAssociatedRecord

  has_encrypted :organisation, :job_title, :main_duties

  # This class represents 2 concerns - 'job' and 'break' (from employment)
  # which might have been better modelled as 2 different types
  enum :employment_type, { job: 0, break: 1 }

  # KSIE dictates that we need a reason_for_leaving even for current role
  validates :organisation, :job_title, :main_duties, :reason_for_leaving, presence: true, if: -> { job? }
  validates :started_on, tvs_date: { before: :today }, if: -> { job? }

  validates :ended_on, tvs_date: { before: :today, on_or_after: :started_on }, unless: -> { is_current_role? }, if: -> { job? }
  validates :ended_on, absence: true, if: -> { job? && is_current_role? }
end
