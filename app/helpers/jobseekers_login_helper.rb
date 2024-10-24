module JobseekersLoginHelper
  include Jobseekers::GovukOneLogin::Helper

  def jobseeker_login_uri
    params = generate_login_params
    session[:govuk_one_login_state] = params[:state]
    session[:govuk_one_login_nonce] = params[:nonce]

    govuk_one_login_uri(:login, params)
  end

  def jobseeker_logout_uri
    params = generate_logout_params(session[:govuk_one_login_id_token])
    govuk_one_login_uri(:logout, params)
  end

  def jobseeker_login_button(class: "")
    govuk_button_link_to(t("buttons.one_login_sign_in"), jobseeker_login_uri.to_s, class:)
  end
end
