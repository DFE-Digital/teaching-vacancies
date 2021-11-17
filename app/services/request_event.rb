##
# Represents events occurring as part of the Rails request lifecycle
#
# This includes additional information in the event that allows us to put the event into the
# context of a user request. This event can only meaningfully be triggered in controllers.
class RequestEvent < Event
  def initialize(request, response, session, current_jobseeker, current_publisher)
    @request = request
    @response = response
    @session = session
    @current_jobseeker = current_jobseeker
    @current_publisher = current_publisher
  end

  private

  attr_reader :request, :response, :session, :current_jobseeker, :current_publisher

  def base_data
    Rollbar.log(:info, request.referer)
    @base_data ||= super.merge(
      request_uuid: request.uuid,
      request_user_agent: user_agent,
      request_referer: request.referer,
      request_method: request.method,
      request_path: request.path,
      request_query: request.query_string,
      request_ab_tests: ab_tests,
      response_content_type: response.content_type,
      response_status: response.status,
      user_anonymised_request_identifier: anonymise(request_identifier),
      user_anonymised_session_id: anonymise(session.id),
      user_anonymised_jobseeker_id: anonymise(current_jobseeker&.id),
      user_anonymised_publisher_id: anonymise(current_publisher&.oid),
    )
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
