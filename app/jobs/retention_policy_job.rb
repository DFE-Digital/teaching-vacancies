class RetentionPolicyJob < ApplicationJob
  queue_as :low

  def scopes
    Enumerator.new do |y|
      JobApplication.after_submission.where(submitted_at: ...threshold).tap do |job_applications|
        # self-disclosure data
        y << SelfDisclosure.joins(self_disclosure_request: :job_application).merge(job_applications)
        y << SelfDisclosureRequest.joins(:job_application).merge(job_applications)
        # reference data
        y << JobReference.joins(referee: :job_application).merge(job_applications)
        y << ReferenceRequest.joins(referee: :job_application).merge(job_applications)
        # qualifying active job applications
        y << job_applications
      end

      # draft job application when vacancy expired
      y << JobApplication.joins(:vacancy).draft.where(updated_at: ...threshold).merge(Vacancy.expired)

      y << Feedback.where(created_at: ...threshold) if hard_delete?
    end
  end

  def threshold
    raise "define thresold period in subclass"
  end

  def hard_delete?
    false
  end
end
