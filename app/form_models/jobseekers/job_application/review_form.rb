class Jobseekers::JobApplication::ReviewForm < Jobseekers::JobApplication::PreSubmitForm
  attr_accessor :confirm_data_accurate, :confirm_data_usage, :update_profile

  validates_acceptance_of :confirm_data_accurate, :confirm_data_usage,
                          acceptance: true,
                          if: :all_steps_completed?
  def update_profile_qualifications?
    update_profile&.include?("qualifications")
  end

  def update_profile_work_history?
    update_profile&.include?("work_history")
  end

  def update_profile_training_and_cpds?
    update_profile&.include?("training_and_cpds")
  end
end
