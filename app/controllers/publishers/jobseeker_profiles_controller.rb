class Publishers::JobseekerProfilesController < ApplicationController
  def index
    @pagy, @jobseeker_profiles = pagy(JobseekerProfileQuery.new(params, current_organisation))
    @form = Publishers::JobseekerProfilesForm.new(jobseeker_profiles_params).call
  end

  private

  def jobseeker_profiles_params
    params.permit(qualified_teacher_status: [], preferred_role: [])
  end
end
