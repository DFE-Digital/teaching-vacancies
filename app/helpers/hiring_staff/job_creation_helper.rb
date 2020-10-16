module HiringStaff::JobCreationHelper
  NUMBER_OF_ADDITIONAL_STEPS_FOR_SCHOOL_GROUP_USERS = 1

  def current_step
    step = params[:create_step]
    if school_group_user?
      step
    else
      step - NUMBER_OF_ADDITIONAL_STEPS_FOR_SCHOOL_GROUP_USERS
    end
  end

  def steps_to_display
    steps = Rails.application.routes.routes.select { |r| r.defaults.key?(:create_step) && r.defaults.key?(:step_title) }
                                           .map { |r| { number: r.defaults[:create_step], title: r.defaults[:step_title] } }
                                           .sort_by { |r| r[:number] }.uniq { |r| r[:number] }

    unless school_group_user?
      steps = remove_school_group_user_only_steps(steps)
      steps = renumber_steps_for_single_school_users(steps)
    end
    steps
  end

  def remove_school_group_user_only_steps(steps)
    # Step 1a and 1b: Job location and school selection
    NUMBER_OF_ADDITIONAL_STEPS_FOR_SCHOOL_GROUP_USERS.times { steps.delete(steps.first) }
    steps
  end

  def renumber_steps_for_single_school_users(steps)
    steps.each { |step| step[:number] -= NUMBER_OF_ADDITIONAL_STEPS_FOR_SCHOOL_GROUP_USERS }
    steps
  end

  def total_steps
    steps_to_display.size
  end

  def set_active_step_class(step_number)
    return 'app-step-nav__step--active' if current_step == step_number
  end

  def set_visited_step_class(step_number, vacancy)
    completed_step = 0
    if vacancy.present?
      completed_step = vacancy.completed_step.presence || 0
    elsif session[:vacancy_attributes].present?
      completed_step = session[:vacancy_attributes]['completed_step'].presence || 0
    end
    return 'app-step-nav__step--visited' if
      step_number != current_step && step_number <= completed_step
  end
end
