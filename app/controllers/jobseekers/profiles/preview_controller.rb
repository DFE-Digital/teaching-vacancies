class Jobseekers::Profiles::PreviewController < Jobseekers::ProfilesController
  def show
    @profile = JobseekerProfile.where(jobseeker_id: current_jobseeker.id).first
  end
end
