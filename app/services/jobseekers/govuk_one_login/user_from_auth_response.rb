class Jobseekers::GovukOneLogin::UserFromAuthResponse
  include Jobseekers::GovukOneLogin::Errors

  attr_reader :auth_response, :session

  def initialize(auth_response, session)
    @auth_response = auth_response
    @session = session
  end

  def call
    validate_user_session
    validate_auth_response

    client = Jobseekers::GovukOneLogin::Client.new(auth_response["code"])

    tokens_response = client.tokens
    validate_tokens_response(tokens_response)

    id_token = client.decode_id_token(tokens_response["id_token"])[0]
    validate_id_token(id_token)

    user_id = id_token["sub"]
    user_info_response = client.user_info(tokens_response["access_token"])
    validate_user_info(user_info_response, user_id)

    Jobseekers::GovukOneLogin::User.new(id: user_id,
                                        email: user_info_response["email"],
                                        id_token: tokens_response["id_token"])
  end

  def self.call(auth_response, session)
    new(auth_response, session).call
  end

  private

  def validate_auth_response
    raise AuthenticationError.new(auth_response["error"], auth_response["error_description"]) if auth_response["error"].present?
    raise AuthenticationError.new("Missing", "'code' is missing") if auth_response["code"].blank?
    raise AuthenticationError.new("Missing", "'state' is missing") if auth_response["state"].blank?
    raise AuthenticationError.new("Invalid", "'state' doesn't match the user session 'state' value") if auth_response["state"] != session[:govuk_one_login_state]
  end

  def validate_user_session
    raise SessionKeyError.new("Missing key", "'govuk_one_login_state' is not set in the user session") if session[:govuk_one_login_state].blank?
    raise SessionKeyError.new("Missing key", "'govuk_one_login_nonce' is not set in the user session") if session[:govuk_one_login_nonce].blank?
  end

  def validate_tokens_response(response)
    raise TokensError.new("Missing", "The tokens response is empty") if response.blank?
    raise TokensError.new(response["error"], response["error_description"]) if response["error"].present?
    raise TokensError.new("Missing", "'access_token' is missing") if response["access_token"].blank?
    raise TokensError.new("Missing", "'id_token' is missing") if response["id_token"].blank?
  end

  def validate_id_token(id_token)
    raise IdTokenError.new("Missing", "The id token is empty") if id_token.blank?
    raise IdTokenError.new("Invalid", "'nonce' doesn't match the user session 'nonce' value") if id_token["nonce"] != session[:govuk_one_login_nonce]
    raise IdTokenError.new("Invalid", "'iss' doesn't match the value configured in our service") if id_token["iss"] != "#{Rails.application.config.govuk_one_login_base_url}/"
    raise IdTokenError.new("Invalid", "'aud' doesn't match our client id") if id_token["aud"] != Rails.application.config.govuk_one_login_client_id
  end

  def validate_user_info(user_info, govuk_one_login_id)
    raise UserInfoError.new("Missing", "The user info is empty") if user_info.blank?
    raise UserInfoError.new(user_info["error"], user_info["error_description"]) if user_info["error"].present?
    raise UserInfoError.new("Missing", "'email' is missing") if user_info["email"].blank?
    raise UserInfoError.new("Invalid", "'sub' doesn't match the user id") if user_info["sub"] != govuk_one_login_id
  end
end
