# frozen_string_literal: true

class Jobseekers::JobApplications::BaptismCertificatesController < Jobseekers::JobApplications::BaseController
  before_action :set_job_application

  def destroy
    # Only the attachment is purged here - religious_reference_type and the catholic step's
    # completed/in_progress state are intentionally left untouched. CatholicForm's baptism_certificate
    # validation (unconditional on section_completed) will refuse to save the catholic step again until
    # the jobseeker either re-attaches a file or picks a different religious_reference_type, so the
    # resulting mismatch (type == "baptism_certificate" with no attachment) can never be persisted.
    job_application.baptism_certificate.purge_later
    redirect_to jobseekers_job_application_build_path(job_application, :catholic)
  end

  private

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  alias_method :set_job_application, :job_application
end
