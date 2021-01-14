class Jobseekers::ApplicationController < ApplicationController
  before_action :store_jobseeker_location!, if: :storable_location?
  before_action :authenticate_jobseeker!

  private

  def storable_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_jobseeker_location!
    store_location_for(:jobseeker, request.fullpath)
  end
end
