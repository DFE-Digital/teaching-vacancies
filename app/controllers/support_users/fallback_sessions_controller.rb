class SupportUsers::FallbackSessionsController < ApplicationController
  layout "application_supportal"

  SIGNED_ID_PURPOSE = :support_user_fallback_sign_in
  SIGNED_ID_VALIDITY = 5.minutes

  before_action :ensure_fallback_sign_in_enabled

  def create
    email = params.require(:support_user).permit(:email)[:email]
    support_user = SupportUser.find_by(email: email)
    return unless support_user

    signed_id = support_user.signed_id(purpose: SIGNED_ID_PURPOSE, expires_in: SIGNED_ID_VALIDITY)
    SupportUsers::AuthenticationFallbackMailer
      .sign_in_fallback(support_user: support_user, signed_id: signed_id)
      .deliver_later
  end

  def show
    support_user = SupportUser.find_signed!(params[:id], purpose: SIGNED_ID_PURPOSE)

    sign_in(:support_user, support_user)
    redirect_to support_user_root_path
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    not_found
  end

  private

  def ensure_fallback_sign_in_enabled
    return if AuthenticationFallback.enabled?

    redirect_to new_support_user_session_path
    false
  end
end
