class HiringStaff::SessionsController < HiringStaff::BaseController
  protect_from_forgery with: :null_session, only: %i[destroy]

  skip_before_action :check_session, only: %i[destroy]
  skip_before_action :check_terms_and_conditions, only: %i[destroy]

  def destroy
    redirect_to dsi_logout_url
  end

  private

  def dsi_logout_url
    url = URI.parse("#{ENV['DFE_SIGN_IN_ISSUER']}/session/end")
    url.query = { post_logout_redirect_uri: auth_dfe_signout_url, id_token_hint: session[:id_token] }.to_query
    url.to_s
  end

  def redirect_to_dfe_sign_in
    # This is defined by the class name of our Omniauth strategy
    redirect_to '/auth/dfe'
  end
end
