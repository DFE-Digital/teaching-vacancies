# Subclasses RequestEvent in order to omit data from monitoring where it is irrelevant for API requests.
class ApiRequestEvent < RequestEvent
  def initialize(request, response, session)
    @request = request
    @response = response
    @session = session
  end

  def base_data
    @base_data ||= super.except(:request_ab_tests, :user_anonymised_jobseeker_id, :user_anonymised_publisher_id, :user_anonymised_support_user_id)
  end
end
