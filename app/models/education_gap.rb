# frozen_string_literal: true

class EducationGap < EmploymentRecord
  belongs_to :job_application

  self.table_name = "employments"
end
