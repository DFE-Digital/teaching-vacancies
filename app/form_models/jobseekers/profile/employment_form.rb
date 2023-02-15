class Jobseekers::Profile::EmploymentForm < BaseForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  def self.fields
    %i[organisation job_title main_duties current_role jobseeker_profile_id]
  end
  attr_accessor(*fields)

  attr_reader :started_on, :ended_on

  validates :organisation, presence: true
  validates :job_title, presence: true
  validates :started_on, presence: true
  validates :started_on, date: { before: :ended_on }, if: -> { ended_on.present? }
  validates :current_role, inclusion: { in: %w[yes no] }
  validates :ended_on, presence: true, unless: -> { current_role == "yes" }
  validates :ended_on, date: { after: :started_on }, unless: -> { current_role == "yes" }
  validates :main_duties, presence: true

  def started_on=(value)
    @started_on = date_from_multiparameter_hash(value)
  end

  def ended_on=(value)
    @ended_on = date_from_multiparameter_hash(value)
  end
end
