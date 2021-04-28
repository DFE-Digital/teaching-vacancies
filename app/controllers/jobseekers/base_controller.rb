class Jobseekers::BaseController < ApplicationController
  before_action :store_jobseeker_location!, if: :storable_location?
  before_action :authenticate_jobseeker!

  private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_jobseeker_location!
    store_location_for(:jobseeker, request.fullpath)
  end

  def update_in_progress_steps!(step)
    job_application.in_progress_steps = job_application.in_progress_steps.append(step.to_s).uniq
    job_application.save
  end
end
