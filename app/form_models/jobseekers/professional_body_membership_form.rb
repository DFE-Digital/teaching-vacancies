class Jobseekers::ProfessionalBodyMembershipForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :exam_taken, :boolean

  attr_accessor :name, :membership_type, :membership_number, :year_membership_obtained

  validates :name, presence: true
  validates :exam_taken, inclusion: { in: [true, false] }
end
