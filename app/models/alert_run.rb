class AlertRun < ApplicationRecord
  enum :status, { pending: 0, sent: 1 }
  belongs_to :subscription

  scope :for_today, -> { where(run_on: Date.current) }
end
