class Employment < ApplicationRecord
  belongs_to :job_application, optional: true
  belongs_to :jobseeker_profile, optional: true
  has_encrypted :organisation, :job_title, :main_duties

  enum :employment_type, { job: 0, break: 1 }

  # Follow the stardard Google deployment pattern for is_current_role:
  # 1. Add new column
  # 2. Populate new column alongside old
  # 3. backfill new column at leisure
  # 4. start using new column
  # 5. remove old column
  # add this once column has been backfilled
  self.ignored_columns += %i[current_role]

  def duplicate
    self.class.new(
      is_current_role:,
      employment_type:,
      ended_on:,
      job_title:,
      main_duties:,
      organisation:,
      reason_for_break:,
      salary:,
      started_on:,
      subjects:,
      reason_for_leaving:,
    )
  end

  def current_role?
    is_current_role
  end
end
