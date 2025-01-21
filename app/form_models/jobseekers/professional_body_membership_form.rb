class Jobseekers::ProfessionalBodyMembershipForm
  include ActiveModel::Model

  attr_accessor :name, :membership_type, :membership_number, :date_membership_obtained, :exam_taken

  validates :name, presence: true
  validates :exam_taken, inclusion: { in: [true, false, "true", "false"] }, if: -> { exam_taken.present? }
end
