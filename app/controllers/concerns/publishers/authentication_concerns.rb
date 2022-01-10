module Publishers::AuthenticationConcerns
  extend ActiveSupport::Concern

  included do
    helper_method :current_organisation
  end

  def current_organisation
    @current_organisation ||= Organisation.find_by(id: session[:publisher_organisation_id])
  end

  def sign_out_publisher!
    session.delete(:publisher_id)
    session.delete(:publisher_organisation_id)
    session.delete(:publisher_dsi_token)
    sign_out(:publisher)
  end

  def trigger_publisher_sign_in_event(success_or_failure, sign_in_type, publisher_oid = nil)
    request_event.trigger(
      :publisher_sign_in_attempt,
      user_anonymised_publisher_id: StringAnonymiser.new(publisher_oid),
      success: success_or_failure == :success,
      sign_in_type:,
    )
  end
end
