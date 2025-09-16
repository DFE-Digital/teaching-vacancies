# In order to maintain anonymity
# we update the equal opportunities report in a job after job_application is submitted
# so that the analytic events' request_uuid are different and avoid matching of
# job application with equal opportunities data

class EqualOpportunitiesReportUpdateJob < ApplicationJob
  queue_as :low

  def perform(job_application_id)
    job_application = JobApplication.includes(:vacancy).find(job_application_id)
    job_application.fill_in_report_and_reset_attributes!
  end
end
