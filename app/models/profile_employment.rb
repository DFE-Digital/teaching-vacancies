class ProfileEmployment < EmploymentRecord
  belongs_to :jobseeker_profile

  has_encrypted :organisation, :job_title

  self.table_name = "employments"
end
