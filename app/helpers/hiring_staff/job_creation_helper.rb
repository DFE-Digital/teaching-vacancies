module HiringStaff::JobCreationHelper
  def current_step
    step = params[:create_step]
    if school_group_user?
      step
    else
      step - HiringStaff::Vacancies::ApplicationController::NUMBER_OF_ADDITIONAL_STEPS_FOR_SCHOOL_GROUP_USERS
    end
  end

  def steps_to_display
    steps_to_display = Rails.application.routes.routes.select { |r|
      r.defaults.has_key?(:create_step) && r.defaults.has_key?(:step_title)
    }.map { |r|
      { number: r.defaults[:create_step], title: r.defaults[:step_title] }
    }.sort_by { |r| r[:number] }.uniq { |r| r[:number] }

    unless school_group_user?
      # Remove steps that apply only to school-group level users
      steps_to_display.delete(steps_to_display.first)
      # Renumber the steps
      steps_to_display.each { |step| step[:number] -= 1 }
    end
    steps_to_display
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
    end
    return 'app-step-nav__step--visited' if
      step_number != current_step && step_number <= completed_step
  end

  def school_group_user?
    session[:uid] != '' && session[:uid] != nil
  end
end
