class SupportUsers::ServiceData::JobseekerProfilesController < SupportUsers::ServiceData::BaseController
  def index
    @jobseeker_profiles = JobseekerProfile.all.order(created_at: :desc)
  end

  def show
    @jobseeker_profile = JobseekerProfile.find(params[:id])
  end
end
