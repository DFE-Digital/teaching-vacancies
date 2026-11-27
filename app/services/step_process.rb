class StepProcess
  attr_reader :current_step, :step_groups, :all_steps

  # StepProcess now takes a hash of hashes, with true if the step is valid and false otherwise
  # This allows the controller to skip non-relevant steps whilst understanding the full step sequence
  def initialize(current_step, step_groups)
    @current_step = current_step.to_sym
    @step_groups = step_groups.compact_blank.transform_values { |hash| hash.select { |_k, v| v }.keys }
    @all_steps = step_groups.compact_blank.values.reduce({}) { |collection, hash| collection.merge(hash) }
  end

  # Returns the keys of all individual steps in order
  def steps
    step_groups.values.flatten
  end

  # Returns the key of the current step group (i.e. the step group the current step is in)
  def current_step_group
    step_groups.find { |_, steps| current_step.in?(steps) }.first
  end

  # Returns the position of the current step group out of the whole set of groups
  def current_step_group_number
    step_groups.keys.index(current_step_group) + 1
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

  def first_step_for_group(section)
    step_groups.fetch(section).first
  end
end
