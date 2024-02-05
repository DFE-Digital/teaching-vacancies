class Jobseekers::BreakForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment
  include DateAttributeAssignment

  attr_accessor :reason_for_break
  attr_reader :started_on, :ended_on

  validates :reason_for_break, presence: true
  validates :started_on, date: { before: :today }
  validates :ended_on, date: { on_or_before: :today, after: :started_on }

  def started_on=(value)
    @started_on = date_from_multiparameter_hash(value)
  end

  def ended_on=(value)
    @ended_on = date_from_multiparameter_hash(value)
  end
end
