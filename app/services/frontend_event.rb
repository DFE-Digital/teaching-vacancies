##
# Represents events triggered from the frontend through the events API endpoint.
# Overrides some of the original event data with the data for the page the event was triggered on,
# and removes data that isn't relevant for frontend-triggered events that aren't "full" requests.
class FrontendEvent < RequestEvent
  private

  def base_data
    # These are set from the referrer because that is where the event was originally triggered
    # (the actual request itself is to the events API endpoint)
    referer = URI(request.referer)
    path = referer.path
    query_string = referer.query

    super.merge(
      request_path: path,
      request_query: query_string,

      # This data is coming through for the XHR request that triggers the event, but isn't relevant
      # for events triggered on the frontend. The fields are set to `nil` to avoid confusion.
      response_status: nil,
      request_uuid: nil,
      request_referer: nil,
      request_method: nil,
      response_content_type: nil,
    )
  end
end
