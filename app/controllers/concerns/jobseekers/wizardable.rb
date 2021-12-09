module Jobseekers::Wizardable
  private

  def current_step
    step if defined?(step)
  end
end
