class JobseekerProfile < ApplicationRecord
  belongs_to :jobseeker

  has_one :personal_details
  has_one :job_preferences
  has_many :employments

  enum qualified_teacher_status: { yes: 0, no: 1, on_track: 2 }

  def deactivate!
    return unless active?

    update_column(:active, false)
  end
end
