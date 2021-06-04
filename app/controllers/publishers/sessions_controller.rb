class Publishers::SessionsController < Devise::SessionsController
  def create
    publisher = Publisher.find(session[:publisher_id])
    organisation = publisher.organisations.find(params[:organisation_id])

    if publisher.organisations.include?(organisation)
      sign_in(publisher)
      sign_out(:jobseeker)
      session.update(publisher_organisation_id: organisation.id)
      trigger_publisher_sign_in_event(:success, :email)
      redirect_to organisation_path
    else
      trigger_publisher_sign_in_event(:failure, :email, publisher.oid)
      redirect_to new_auth_email_path, notice: t(".not_authorised")
    end
    super
  end

  def destroy
    @publisher_dsi_token = session[:publisher_dsi_token]
    session.delete(:publisher_organisation_id)
    super
  end

  private

  def after_sign_out_path_for(_resource)
    return new_auth_email_path if AuthenticationFallback.enabled?

    url = URI.parse("#{ENV['DFE_SIGN_IN_ISSUER']}/session/end")
    url.query = { post_logout_redirect_uri: new_publisher_session_url, id_token_hint: @publisher_dsi_token }.to_query
    url.to_s
  end

  def after_sign_in_path_for(_resource)
    organisation_path
  end
end
