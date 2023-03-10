class Api::EventsController < Api::ApplicationController
  # Prevent arbitrary events/data from being triggered by the frontend
  EVENT_ALLOWLIST = {
    copied_to_clipboard: %i[description subject],
    tracked_link_clicked: %i[link_type link_subject text href mouse_button],
  }.freeze

  rescue_from ActionController::InvalidAuthenticityToken, with: :bad_request

  def create
    type = event_params[:type].to_sym
    return bad_request unless EVENT_ALLOWLIST.key?(type)

    data = event_params[:data].to_h.slice(*EVENT_ALLOWLIST[type])
    frontend_event.trigger(type, data)
    send_dfe_analytics_event(type, data)

    event = DfE::Analytics::Event.new
     .with_type(type)
     .with_user(current_user)
     .with_data(some: data)

    DfE::Analytics::SendEvents.do([event])

    head :no_content
  end

  private

  def event_params
    params.require(:event).permit(:type, data: {})
  end

  def frontend_event
    FrontendEvent.new(request, response, session, current_jobseeker, current_publisher, current_support_user)
  end

  def bad_request
    head(:bad_request)
  end

  def send_dfe_analytics_event(type, data)
    fail_safe do
      event = DfE::Analytics::Event.new
        .with_type(type)
        .with_request_details(request)
        .with_response_details(response)
        .with_data(data)

      DfE::Analytics::SendEvents.do([event])
    end
  end
end
