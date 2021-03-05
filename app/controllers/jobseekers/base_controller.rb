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

  def redirect_if_vacancy_has_expired
    redirect_to expired_jobseekers_job_job_application_path(vacancy.id) unless vacancy.listed?
  end
end
