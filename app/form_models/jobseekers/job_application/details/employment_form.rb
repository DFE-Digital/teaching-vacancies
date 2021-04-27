class Jobseekers::JobApplication::Details::EmploymentForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :organisation, :job_title, :salary, :subjects, :main_duties, :started_on, :current_role, :ended_on

  validates :organisation, :job_title, :main_duties, presence: true
  validates :started_on, presence: true, date: true
  validate :started_on_is_in_the_past
  validates :current_role, inclusion: { in: %w[yes no] }
  validates :ended_on, presence: true, date: true, if: -> { current_role == "no" }
  validate :ended_on_is_in_the_past, if: -> { current_role == "no" }
  validate :ended_on_is_after_started_on, if: -> { current_role == "no" }

  def started_on_is_in_the_past
    return if started_on.nil?

    errors.add(:started_on, :not_in_the_past) unless started_on_date < Date.current
  rescue Date::Error, TypeError
    nil
  end

  def ended_on_is_in_the_past
    return if ended_on.nil?

    errors.add(:ended_on, :not_in_the_past) unless ended_on_date < Date.current
  rescue Date::Error, TypeError
    nil
  end

  def ended_on_is_after_started_on
    return if ended_on.nil? || started_on.nil?

    errors.add(:ended_on, :before_started_on) unless ended_on_date > started_on_date
  rescue Date::Error, TypeError
    nil
  end

  def started_on_date
    @started_on_date ||= Date.new(started_on[1], started_on[2], started_on[3])
  end

  def ended_on_date
    @ended_on_date ||= Date.new(ended_on[1], ended_on[2], ended_on[3])
  end
end
