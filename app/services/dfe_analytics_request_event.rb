class DfeAnalyticsRequestEvent < RequestEvent
  def request_data
    {}
  end

  def response_data
    {}
  end

  def user_data
    {
      user_anonymised_session_id: anonymise(session.id),
    }
  end
end
