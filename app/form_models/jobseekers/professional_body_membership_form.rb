class Jobseekers::ProfessionalBodyMembershipForm
  include ActiveModel::Model

  attr_accessor :name, :membership_type, :membership_number, :year_membership_obtained, :exam_taken

  validates :name, presence: true
  validates :exam_taken, inclusion: { in: [true, false, "true", "false"] }
end
