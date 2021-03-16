class Shared::ProcessStepsComponent < ViewComponent::Base
  def initialize(process:, service:, title:)
    @process = process
    @service = service
    @title = title
  end

  def render?
    @process.blank? || %w[create draft review].include?(process_state)
  end

  def current_step_number
    @service.current_step_number
  end

  def completed_step_number
    if @process.is_a?(JobApplication)
      @process.completed_steps.map { |step| @service.steps[step.to_sym][:number] }.max
    else
      @process.completed_step
    end
  end

  def process_state
    return @process.status if @process.is_a?(JobApplication)

    @process.state
  end

  def steps_to_display
    @service.steps_to_display
  end

  def total_steps
    @service.total_steps
  end

  def active_step_class(step_number, current_step_number)
    return "process-steps-component__step--active" if current_step_number == step_number
  end

  def visited_step_class(step_number, completed_step)
    return "process-steps-component__step--visited" if
      step_number != current_step_number && step_number <= completed_step
  end
end
