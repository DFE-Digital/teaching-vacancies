module PreInterviewingHelper
  def can_send_reminder?(request)
    request.updated_at < 2.business_days.ago && request.pending?
  end
end
