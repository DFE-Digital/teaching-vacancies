class Jobseekers::Profile::EmploymentForm < BaseForm
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment
  include ActiveModel::Attributes

  FIELDS = %i[organisation job_title main_duties jobseeker_profile_id subjects reason_for_leaving].freeze

  def self.fields
    FIELDS + %i[is_current_role]
  end
  attr_accessor(*FIELDS)

  attr_reader :started_on, :ended_on

  validates :organisation, :job_title, :main_duties, presence: true
  validates :reason_for_leaving, presence: true, unless: -> { is_current_role }
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
