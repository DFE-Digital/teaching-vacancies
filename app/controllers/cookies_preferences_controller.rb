class CookiesPreferencesController < ApplicationController
  before_action :set_previous_url_in_session

  def new
    # TODO: Remove "consented-to-cookies" check after Dec 2023 (6 months from this comment). That cookie
    # won't be valid anymore.
    cookies_analytics_consent =
      if cookies["consented-to-analytics-cookies"] == "yes" || cookies["consented-to-cookies"] == "yes"
        "yes"
      else
        "no"
      end
    cookies_marketing_consent = cookies["consented-to-marketing-cookies"] == "yes" ? "yes" : "no"
    @cookies_preferences_form = CookiesPreferencesForm.new(cookies_analytics_consent:, cookies_marketing_consent:)
  end

  def create
    @cookies_preferences_form = CookiesPreferencesForm.new(cookies_preferences_params)

    if @cookies_preferences_form.valid?
      cookies["consented-to-analytics-cookies"] =
        { value: @cookies_preferences_form.cookies_analytics_consent, expires: 6.months.from_now }
      cookies["consented-to-marketing-cookies"] =
        { value: @cookies_preferences_form.cookies_marketing_consent, expires: 6.months.from_now }

      redirect_to(session[:previous_url], success: I18n.t("cookies_preferences.success")) unless params[:no_redirect]
    else
      render :new
    end
  end

  def cookies_preference_set?
    true
  end

  private

  def cookies_preferences_params
    (params[:cookies_preferences_form] || params).permit(:cookies_analytics_consent, :cookies_marketing_consent)
  end

  def set_previous_url_in_session
    previous_uri = request.referrer.present? ? URI(request.referrer) : nil
    session[:previous_url] = previous_uri&.request_uri unless previous_uri&.path == cookies_preferences_path
    session[:previous_url] = root_path if session[:previous_url].nil?
  end
end
