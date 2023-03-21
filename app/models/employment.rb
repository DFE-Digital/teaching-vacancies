class Employment < ApplicationRecord
  belongs_to :job_application, optional: true
  belongs_to :jobseeker_profile, optional: true
  has_encrypted :organisation, :job_title, :main_duties

  enum employment_type: { job: 0, break: 1 }

  def duplicate
    self.class.new(
      current_role:,
      employment_type:,
      ended_on:,
      job_title:,
      main_duties:,
      organisation:,
      reason_for_break:,
      salary:,
      started_on:,
      subjects:,
    )
  end

  def current_role?
    current_role == "yes"
  end
end
