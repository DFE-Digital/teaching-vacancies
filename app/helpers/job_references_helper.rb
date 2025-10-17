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
    elsif reference_request.received_off_service?
      "received"
    else
      "created"
    end
  end

  def religious_request_status(religious_reference_request)
    if religious_reference_request.action_needed?
      "action"
    elsif religious_reference_request.requested?
      "pending"
    else
      "completed"
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

  def self_disclosure_status(self_disclosure_request)
    if self_disclosure_request.marked_as_complete?
      "completed"
    elsif self_disclosure_request.status.in? %w[received_off_service received]
      "received"
    elsif self_disclosure_request.sent?
      "pending"
    else
      "created"
    end
  end
end
