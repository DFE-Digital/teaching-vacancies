class Jobseekers::JobApplication::Details::EmploymentForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :organisation, :job_title, :salary, :subjects, :main_duties, :started_on, :current_role, :ended_on, :reason_for_leaving

  validates :organisation, :job_title, :main_duties, presence: true
  validates :started_on, presence: true, date: true
  validates :current_role, inclusion: { in: %w[yes no] }
  validates :reason_for_leaving, presence: true, if: -> { current_role == "no" }
  validates :ended_on, presence: true, date: true, if: -> { current_role == "no" }
  validate :ended_on_is_after_started_on, if: -> { current_role == "no" }

  def ended_on_is_after_started_on
    return if ended_on.nil? || started_on.nil?

    errors.add(:ended_on, :before_started_on) unless
      Date.new(ended_on[1], ended_on[2], ended_on[3]) > Date.new(started_on[1], started_on[2], started_on[3])
  rescue Date::Error
    nil
  end
end
