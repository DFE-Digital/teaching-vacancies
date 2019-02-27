class AuditData < ApplicationRecord
  self.table_name = 'audit_data'

  enum category: %i[
    vacancies
    sign_in_events
    interest_expression
    search_event
    feedback
    toc_acceptance
  ]
end
