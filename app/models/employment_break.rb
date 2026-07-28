# frozen_string_literal: true

class EmploymentBreak < EmploymentRecord
  belongs_to :job_application

  self.table_name = "employments"
end
