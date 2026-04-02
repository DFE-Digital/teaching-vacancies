# frozen_string_literal: true

class Jobseekers::JobApplications::BaptismCertificatesController < Jobseekers::JobApplications::BaseController
  before_action :set_job_application

  def destroy
    # calling purge rather than purge_later to avoid potential confusing UX where user clicks delete and get returned 
    # to the page before the file is deleted and still sees the file they tried to delete
    job_application.baptism_certificate.purge
    redirect_to jobseekers_job_application_build_path(job_application, :catholic)
  end

  private

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  alias set_job_application job_application
end
