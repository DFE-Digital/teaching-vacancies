class ProfileEmployment < EmploymentRecord
  belongs_to :jobseeker_profile

  has_encrypted :organisation, :job_title

  self.table_name = "employments"

  # these fields are not used in the profile version
  self.ignored_columns += %i[main_duties subjects reason_for_leaving]
end
