class Jobseekers::Profiles::PreviewController < Jobseekers::ProfilesController
  include VacanciesHelper

  def show
    @personal_details = PersonalDetails.where(jobseeker_profile_id: jobseeker_profile.id).first
    @job_preferences = JobPreferences.where(jobseeker_profile_id: jobseeker_profile.id).first
  end

  private

  def jobseeker_profile
    JobseekerProfile.where(jobseeker_id: current_jobseeker.id).first
  end
end
