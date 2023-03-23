class Publishers::JobseekerProfilesController < Publishers::BaseController
  def index
    @pagy, @jobseeker_profiles = pagy(Search::JobseekerProfileSearch.new(jobseeker_profile_search_params).jobseeker_profiles)
    @form = Publishers::JobseekerProfileSearchForm.new(jobseeker_profile_search_params)
  end

  def show
    not_found unless profile.active?
  end

  private

  def jobseeker_profile_search_params
    params.permit(locations: [], qualified_teacher_status: [], roles: [], working_patterns: [], education_phases: [], key_stages: [], subjects: [])
          .transform_values(&:compact_blank)
          .merge(current_organisation:)
  end

  def profile
    @profile ||= JobseekerProfile.find(params[:id])
  end
  helper_method :profile
end
