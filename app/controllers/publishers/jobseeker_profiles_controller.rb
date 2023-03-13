class Publishers::JobseekerProfilesController < Publishers::BaseController
  def index
    @pagy, @jobseeker_profiles = pagy(JobseekerProfileQuery.new(jobseeker_profiles_params, current_organisation).call)
    @form = Publishers::JobseekerProfilesForm.new(jobseeker_profiles_params)
  end

  def show; end

  private

  def jobseeker_profiles_params
    params.permit(qualified_teacher_status: [], roles: [], working_patterns: [], key_stages: [], education_phases: [])
  end

  def profile
    @profile ||= JobseekerProfile.find(params[:id])
  end
  helper_method :profile

  def can_invite?
    Publishers::InviteForm.new(organisation_id: current_organisation.id, jobseeker_profile_id: profile.id).applicable_jobs.any?
  end
  helper_method :can_invite?
end
