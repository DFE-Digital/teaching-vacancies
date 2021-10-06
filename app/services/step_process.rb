class StepProcess
  attr_reader :current_step, :step_groups

  class MissingStepError < ArgumentError; end

  def initialize(current_step, step_groups = {})
    @current_step = current_step.to_sym
    @step_groups = step_groups.select { |_, steps| steps.present? }

    raise MissingStepError, "Current step `#{current_step}` missing from steps (#{steps.join(', ')})" unless current_step.in?(steps)
  end

  # Returns the keys of all individual steps in order
  def steps
    step_groups.values.flatten
  end

  # Returns the key of the current step group (i.e. the step group the current step is in)
  def current_step_group
    step_groups.find { |_, steps| current_step.in?(steps) }.first
  end

  # Returns all the steps in the same group as the current step
  def steps_in_current_group
    step_groups[current_step_group]
  end

  # Returns the position of the current step group out of the whole set of groups
  def current_step_group_number
    step_groups.keys.index(current_step_group) + 1
  end

  # Returns the total number of all applicable step groups
  def total_step_groups
    step_groups.size
  end

  # Returns whether the current step is the first (or only) step in its group
  def first_of_group?
    current_step == steps_in_current_group.first
  end

  # Returns whether the current step is the final (or only) step in its group
  def last_of_group?
    current_step == steps_in_current_group.last
  end

  # Returns the key of the next step from the current one
  def next_step
    return nil if current_step == steps.last

    steps[steps.index(current_step) + 1]
  end

  # Returns the key of the previous step from the current one
  def previous_step
    return nil if current_step == steps.first

    steps[steps.index(current_step) - 1]
  end

  # Returns whether the current step is the first step in the entire process
  def first_step?
    current_step == steps.first
  end

  # Returns whether the current step is the last step in the entire process
  def last_step?
    current_step == steps.last
  end
end
