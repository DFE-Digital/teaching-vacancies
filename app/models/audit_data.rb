class AuditData < ApplicationRecord
  self.table_name = "audit_data"

  enum category: {
    vacancies: 0,
    sign_in_events: 1,
    interest_expression: 2,
    search_event: 3,
    toc_acceptance: 4,
    subscription_creation: 5,
  }

  def to_row
    data.values.unshift(Time.current.to_s)
  end
end
