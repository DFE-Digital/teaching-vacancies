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
end
