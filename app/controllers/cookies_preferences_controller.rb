class CookiesPreferencesController < ApplicationController
  before_action :redirect_unless_cookies_feature_enabled
  before_action :set_previous_url_in_session

  def new
    @cookies_preferences_form = CookiesPreferencesForm.new({ cookies_consent: cookies['consented-to-cookies'] })
  end

  def create
    @cookies_preferences_form = CookiesPreferencesForm.new(cookies_preferences_params)

    if @cookies_preferences_form.valid?
      cookies['consented-to-cookies'] = { value: @cookies_preferences_form.cookies_consent, expires: 6.months.from_now }
      redirect_to session[:previous_url]
    else
      render :new
    end
  end

private

  def cookies_preferences_params
    (params[:cookies_preferences_form] || params).permit(:cookies_consent)
  end

  def redirect_unless_cookies_feature_enabled
    redirect_to page_path('cookies') unless CookiesBannerFeature.enabled?
  end

  def set_previous_url_in_session
    previous_uri = request.referrer.present? ? URI(request.referrer) : nil
    session[:previous_url] = previous_uri&.request_uri unless previous_uri&.path == cookies_preferences_path
    session[:previous_url] = root_path if session[:previous_url].nil?
  end
end
