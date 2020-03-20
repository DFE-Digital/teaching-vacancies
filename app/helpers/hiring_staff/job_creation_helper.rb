module HiringStaff::JobCreationHelper
  def current_step
    params[:create_step]
  end

  def steps_to_display
    Rails.application.routes.routes.select { |r|
      r.defaults.has_key?(:create_step) && r.defaults.has_key?(:step_title)
    }.map{ |r|
      [r.defaults[:create_step], r.defaults[:step_title]]
    }.sort
  end

  def total_steps
    Rails.application.routes.routes.select { |r| r.defaults.has_key?(:create_step) }.size
  end
end
