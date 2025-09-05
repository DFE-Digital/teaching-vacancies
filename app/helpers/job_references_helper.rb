module JobReferencesHelper
  def reference_request_status(reference_request, job_reference)
    if reference_request.marked_as_complete?
      "completed"
    elsif reference_request.sent?
      if job_reference.complete?
        if job_reference.can_give_reference?
          "received"
        else
          "declined"
        end
      else
        "pending"
      end
    else
      "created"
    end
  end

  def religious_request_status(job_application)
    if job_application.religious_reference_received?
      "received"
    else
      "action"
    end
  end
end
