class Shared::ProcessStepsComponent < ViewComponent::Base
  def initialize(process:, service:)
    @process = process
    @service = service
  end

  def render?
    @process.blank? || %w[create review].include?(@process.state)
  end

  def current_step_number
    @service.current_step_number
  end

  def steps_to_display
    @service.steps_to_display
  end

  def total_steps
    @service.total_steps
  end

  def active_step_class(step_number, current_step_number)
    return "process-steps__step--active" if current_step_number == step_number
  end

  def visited_step_class(step_number, completed_step)
    return "process-steps__step--visited" if
      step_number != current_step_number && step_number <= completed_step
  end
end
