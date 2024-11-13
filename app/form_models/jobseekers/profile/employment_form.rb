class Jobseekers::Profile::EmploymentForm < BaseForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  def self.fields
    %i[organisation job_title main_duties current_role jobseeker_profile_id subjects reason_for_leaving]
  end
  attr_accessor(*fields)

  attr_reader :started_on, :ended_on

  validates :organisation, :job_title, :main_duties, :reason_for_leaving, presence: true
  validates :started_on, date: { before: :today }
  validates :current_role, inclusion: { in: %w[yes no] }
  validates :ended_on, date: { before: :today, on_or_after: :started_on }, if: -> { current_role == "no" }

  def started_on=(value)
    @started_on = date_from_multiparameter_hash(value)
  end

  def ended_on=(value)
    @ended_on = date_from_multiparameter_hash(value)
  end
end
