class Jobseekers::Profile::ChooseSchoolOrTrustForm < BaseForm
  include ActiveRecord::AttributeAssignment

  attr_accessor :organisation_id

  validates :organisation_id, presence: true
end
