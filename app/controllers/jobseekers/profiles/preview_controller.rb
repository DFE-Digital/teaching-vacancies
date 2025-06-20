class Jobseekers::Profiles::PreviewController < Jobseekers::ProfilesController
  def show
    @personal_details = @profile.personal_details
    @job_preferences = @profile.job_preferences
  end
end
