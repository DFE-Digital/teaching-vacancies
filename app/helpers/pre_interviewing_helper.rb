module PreInterviewingHelper
  def can_send_reminder?(request)
    request.updated_at < 48.hours.ago && request.pending?
  end
end
