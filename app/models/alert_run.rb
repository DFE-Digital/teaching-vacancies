class AlertRun < ApplicationRecord
  enum status: %i[pending sent]
  belongs_to :subscription
end