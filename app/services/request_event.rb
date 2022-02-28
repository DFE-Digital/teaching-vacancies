##
# Represents events occurring as part of the Rails request lifecycle
#
# This includes additional information in the event that allows us to put the event into the
# context of a user request. This event can only meaningfully be triggered in controllers.
class RequestEvent < Event
  def initialize(request, response, session, current_jobseeker, current_publisher, current_support_user)
    @request = request
    @response = response
    @session = session
    @current_jobseeker = current_jobseeker
    @current_publisher = current_publisher
    @current_support_user = current_support_user
  end

  private

  attr_reader :request, :response, :session, :current_jobseeker, :current_publisher, :current_support_user

  def base_data
    @base_data ||= super.merge(request_data)
                        .merge(response_data)
                        .merge(user_data)
  end

  def request_data
    {
      request_uuid: request.uuid,
      request_user_agent: user_agent,
      request_referer: request.referer,
      request_method: request.method,
      request_path: request.path,
      request_query: request.query_string,
      request_ab_tests: ab_tests,
    }
  end

  def response_data
    {
      response_content_type: response.content_type,
      response_status: response.status,
    }
  end

  def user_data
    {
      user_anonymised_request_identifier: anonymise(request_identifier),
      user_anonymised_session_id: anonymise(session.id),
      user_anonymised_jobseeker_id: anonymise(current_jobseeker&.id),
      user_anonymised_publisher_id: anonymise(current_publisher&.oid),
      user_anonymised_support_user_id: anonymise(current_support_user&.oid),
    }
  end

  def request_identifier
    [user_agent, request.remote_ip].join
  end

  def user_agent
    request.headers["User-Agent"]
  end

  def ab_tests
    AbTests.new(session).current_variants.map { |test, variant| { test: test, variant: variant } }
  end
end
