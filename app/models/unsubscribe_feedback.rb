class UnsubscribeFeedback < ApplicationRecord
  include Auditor::Model

  belongs_to :subscription

  enum reason: { not_relevant: 0, job_found: 1, circumstances_change: 2, other_reason: 3 }
end
