class Publishers::SessionsController < Devise::SessionsController
  PUBLISHER_SESSION_KEYS = %i[
    publisher_id_token
    publisher_oid
    publisher_multiple_organisations
    organisation_urn
    organisation_uid
    organisation_la_code
  ].freeze

  def destroy
    @id_token_hint = session[:publisher_id_token]

    PUBLISHER_SESSION_KEYS.each { |key| session.delete(key) }
    super
  end

  private

  def after_sign_out_path_for(_resource)
    return new_auth_email_path if AuthenticationFallback.enabled?

    url = URI.parse("#{ENV['DFE_SIGN_IN_ISSUER']}/session/end")
    url.query = { post_logout_redirect_uri: new_publisher_session_url, id_token_hint: @id_token_hint }.to_query
    url.to_s
  end

  def after_sign_in_path_for(_resource)
    organisation_path
  end
end
