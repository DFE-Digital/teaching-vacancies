class Publishers::JobseekerProfilesController < Publishers::BaseController
  def index
    @pagy, @jobseeker_profiles = pagy(Search::JobseekerProfileSearch.new(filters, current_organisation).jobseeker_profiles)
    @form = Publishers::JobseekerProfileSearchForm.new(jobseeker_profile_search_params)
  end

  def show; end

  private

  def jobseeker_profile_search_params
    params.permit(qualified_teacher_status: [], roles: [], working_patterns: [], key_stages: [], education_phases: [])
  end

  def profile
    @profile ||= JobseekerProfile.find(params[:id])
  end
  helper_method :profile
  def filters
    jobseeker_profile_search_params.transform_values(&:compact_blank)
  end
end
