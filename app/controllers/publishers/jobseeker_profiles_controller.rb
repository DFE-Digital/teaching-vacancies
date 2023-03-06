class Publishers::JobseekerProfilesController < Publishers::BaseController
  def index
    @pagy, @jobseeker_profiles = pagy(JobseekerProfileQuery.new(params, current_organisation).call)
    @form = Publishers::JobseekerProfilesForm.new(jobseeker_profiles_params)
  end

  private

  def jobseeker_profiles_params
    params.permit(qualified_teacher_status: [], roles: [], working_patterns: [], key_stages: [], education_phases: [])
  end
end
