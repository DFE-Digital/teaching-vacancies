class AuditData < ApplicationRecord
  self.table_name = 'audit_data'

  enum category: %i[
    vacancies
    sign_in_events
    interest_expression
    search_event
    toc_acceptance
  ]

  def to_row
    data.values.unshift(Time.zone.now.to_s)
  end
end
