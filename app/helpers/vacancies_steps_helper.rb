module VacanciesStepsHelper
  def vacancy_step_completed?(vacancy, step)
    vacancy.completed_steps.include?(step.to_s)
  end

  def total_steps(steps)
    review_step = steps_to_display(steps)[:review]
    adjust_step(review_step)[:number]
  end

  def steps_to_display(steps)
    steps.dup.except!(*steps_to_skip).uniq { |_step, details| details[:number] }.to_h
  end

  def steps_to_skip
    current_organisation.school? ? %i[job_location schools] : %i[]
  end

  def other_parts_of_step_remaining?
    current_step_index = steps_config.keys.index(step)
    later_steps = steps_config.keys[current_step_index..]
    later_step_numbers = steps_config.slice(*later_steps).map { |_step, details| details[:number] }
    later_step_numbers.count(current_step_number) > 1
  end

  def adjusted_current_step_number
    adjust_step(steps_config[(step || :review)])[:number]
  end

  def current_step_number
    @current_step_number ||= steps_config[(step || :review)][:number]
  end

  private

  def adjust_step(step)
    # Generate the right numeral for a step, given that some user journeys skip a step and others don't.
    return step unless steps_to_skip.any?

    # Since some steps share a numeral (see steps_config), we ignore non-unique numerals:
    skipped_step_numbers = steps_to_skip.map { |s| steps_config[s][:number] }.uniq.sort
    # Adjust the numeral by the number of skipped step numerals that come before the current step.
    step.merge({ number: (step[:number] - skipped_step_numbers.count { |number| number < step[:number] }) })
  end
end
