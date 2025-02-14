class Jobseekers::JobApplication::Details::EmploymentForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment
  include ActiveModel::Attributes

  attr_accessor :organisation, :job_title, :subjects, :main_duties, :reason_for_leaving
  attr_reader :started_on, :ended_on

  validates :organisation, :job_title, :main_duties, :reason_for_leaving, presence: true
  validates :started_on, date: { before: :today }
  validates :is_current_role, inclusion: { in: [true, false] }
  validates :ended_on, date: { before: :today, on_or_after: :started_on }, unless: -> { is_current_role }

  attribute :is_current_role, :boolean

  def started_on=(value)
    @started_on = date_from_multiparameter_hash(value)
  end

  def ended_on=(value)
    @ended_on = date_from_multiparameter_hash(value)
  end
end
