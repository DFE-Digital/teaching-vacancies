class ProfileEmployment < EmploymentRecord
  belongs_to :jobseeker_profile

  has_encrypted :organisation, :job_title

  self.table_name = "employments"

  # This model was originally ignoring the following columns from the employments table:
  # - main_duties
  # - subjects
  # -reason_for_leaving
  # These columns have no use in the profile employment model.
  #
  # Unfortunately, this results in the DfE Analytics entity updates not including those keys, causing an inconsistency in
  # 'employments' entity schema in DfE Analytics. As 'Employment' and 'ProfileEmployment' models share the same table,
  # but send different columns to DfE Analytics.
  #
  # TO DO: Check if we can ignore the unneeded columns again.After the Analytics entity feeding has been moved to
  # Airbyte (DB -> Analytics direct updates).
end
