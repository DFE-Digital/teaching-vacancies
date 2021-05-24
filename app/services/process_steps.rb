class ProcessSteps
  attr_reader :steps

  def initialize(steps:, step:, adjust:)
    @steps = steps
    @step = step
    @adjust = adjust
  end

  def current_step_number
    @steps[@step][:number] - @adjust
  end

  def steps_to_display
    steps = @steps.dup
    if @adjust.positive?
      steps = remove_school_group_user_only_steps(steps)
      steps = renumber_steps_for_single_school_users(steps)
    end
    steps
  end

  def remove_school_group_user_only_steps(steps)
    # Step 1a and 1b: Job location and school selection
    steps.delete_if { |_k, v| v[:number] == 1 }
  end

  def renumber_steps_for_single_school_users(steps)
    steps.transform_values do |v|
      { number: v[:number] - @adjust, title: v[:title] }
    end
  end

  def total_steps
    steps_to_display.values.map { |h| h[:number] }.max
  end
end
