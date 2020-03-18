module HiringStaff::JobCreationHelper
  def total_steps
    Rails.application.routes.routes.select { |r| r.defaults.has_key?(:create_step) }.size
  end

  def current_step
    params[:create_step]
  end
end
