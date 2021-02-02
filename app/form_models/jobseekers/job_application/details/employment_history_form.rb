class Jobseekers::JobApplication::Details::EmploymentHistoryForm
  include ActiveModel::Model
  include ActiveRecord::AttributeAssignment

  attr_accessor :organisation, :job_title, :salary, :subjects, :main_duties, :started_on, :current_role, :ended_on, :reason_for_leaving

  validates :organisation, :job_title, :main_duties, :started_on, presence: true
  validate :started_on_is_valid
  validates :current_role, inclusion: { in: %w[yes no] }
  validates :ended_on, :reason_for_leaving, presence: true, if: -> { current_role == "no" }
  validate :ended_on_is_valid
  validate :ended_on_is_after_started_on, if: -> { current_role == "no" && ended_on.is_a?(Date) && started_on.is_a?(Date) }

  # Most of this is necessary because we don't actually store Date objects yet
  def initialize(params = {})
    if params["started_on(1i)"].present? && params["started_on(2i)"].present? && params["started_on(3i)"].present?
      begin
        @started_on = Date.new(
          params.delete("started_on(1i)").to_i,
          params.delete("started_on(2i)").to_i,
          params.delete("started_on(3i)").to_i,
        )
      rescue Date::Error
        @started_on = :invalid
      end
    end

    if params[:current_role] == "no" && params["ended_on(1i)"].present? && params["ended_on(2i)"].present? && params["ended_on(3i)"].present?
      begin
        @ended_on = Date.new(
          params.delete("ended_on(1i)").to_i,
          params.delete("ended_on(2i)").to_i,
          params.delete("ended_on(3i)").to_i,
        )
      rescue Date::Error
        @ended_on = :invalid
      end
    end

    super(params)
  end

  def started_on_is_valid
    errors.add(:started_on, :invalid) if started_on == :invalid
  end

  def ended_on_is_valid
    errors.add(:ended_on, :invalid) if ended_on == :invalid
  end

  def ended_on_is_after_started_on
    errors.add(:ended_on, :before_started_on) unless ended_on > started_on
  end
end
