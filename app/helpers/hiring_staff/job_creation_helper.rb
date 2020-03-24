module HiringStaff::JobCreationHelper
  def current_step
    params[:create_step]
  end

  def steps_to_display
    Rails.application.routes.routes.select { |r|
      r.defaults.has_key?(:create_step) && r.defaults.has_key?(:step_title)
    }.map { |r|
      { number: r.defaults[:create_step], title: r.defaults[:step_title] }
    }.sort_by { |r| r[:number] }.uniq { |r| r[:number] }
  end

  def total_steps
    steps_to_display.size
  end

  def set_active_step_class(step_number)
    return 'app-step-nav__step--active' if current_step == step_number
  end

  def set_visited_step_class(step_number)
    return 'app-step-nav__step--visited' if current_step > step_number
  end
end
