class Publishers::JobseekerProfilesController < ApplicationController
  def index
    @pagy, @jobseeker_profiles = pagy(JobseekerProfile.all)
  end
end
