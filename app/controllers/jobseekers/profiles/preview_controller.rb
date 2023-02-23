class Jobseekers::Profiles::PreviewController < Jobseekers::ProfilesController
  include VacanciesHelper

  def show
    @profile = JobseekerProfile.where(jobseeker_id: current_jobseeker.id).first
    @personal_details = PersonalDetails.where(jobseeker_profile_id: @profile.id).first
    @job_preferences = JobPreferences.where(jobseeker_profile_id: @profile.id).first
  end
end
