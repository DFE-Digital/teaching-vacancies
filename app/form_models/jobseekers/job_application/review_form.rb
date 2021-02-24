class Jobseekers::JobApplication::ReviewForm
  include ActiveModel::Model

  attr_accessor :confirm_data_accurate, :confirm_data_usage, :completed_steps

  validates :confirm_data_accurate, acceptance: true
  validates :confirm_data_usage, acceptance: true
  validate :all_steps_completed

  def all_steps_completed
    return if JobApplication.completed_steps.keys.all? { |step| completed_steps.include?(step) }

    errors.add(:base, "Please complete all incomplete steps")
  end
end
