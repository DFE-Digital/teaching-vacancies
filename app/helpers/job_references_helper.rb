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

  def contact_referees_message(job_applications)
    if job_applications.one?
      "single"
    elsif job_applications.one?(&:notify_before_contact_referers?)
      "one"
    elsif job_applications.all?(&:notify_before_contact_referers?)
      "all"
    else
      "some"
    end
  end
end
