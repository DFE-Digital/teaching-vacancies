class RetentionPolicyJob < ApplicationJob
  queue_as :low

  def scopes
    Enumerator.new do |y|
      job_applications = JobApplication.after_submission.where(submitted_at: ...threshold)

      # self-disclosure data
      y << SelfDisclosure.joins(self_disclosure_request: :job_application).merge(job_applications)
      y << SelfDisclosureRequest.joins(:job_application).merge(job_applications)

      # references data
      y << JobReference.joins(referee: :job_application).merge(job_applications)
      y << ReferenceRequest.joins(referee: :job_application).merge(job_applications)

      y << job_applications
    end
  end

  def threshold
    raise "define thresold period"
  end
end
