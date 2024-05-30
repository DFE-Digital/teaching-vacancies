class SupportUsers::ServiceData::JobseekerProfilesController < SupportUsers::ServiceData::BaseController
  def index
    jobseeker_profiles = JobseekerProfile.includes(:personal_details, :jobseeker).all.order(created_at: :desc)
    @pagy, @jobseeker_profiles = pagy(jobseeker_profiles)
  end

  def show
    @jobseeker_profile = JobseekerProfile.find(params[:id])
    Rails.logger.info("[Service Data] #{current_user.email} accessed Profile ID #{@jobseeker_profile.id} at #{Time.current}")
  end
end
