class HiringStaff::IdentificationsController < HiringStaff::BaseController
  include ActionView::Helpers::OutputSafetyHelper

  skip_before_action :check_session, only: %i[new create sign_in_by_email]
  skip_before_action :check_terms_and_conditions, only: %i[new create sign_in_by_email]
  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :redirect_signed_in_users

  def new
    if EmailSignInFeature.enabled?
      render :authentication_fallback
    end
  end

  def sign_in_by_email
    raise unless EmailSignInFeature.enabled?

    user = User.find_by(email: params.dig(:user, :email))

    if user
      magic_link_token = MagicLinkToken.new
      ProviderMailer.fallback_sign_in_email(provider_user, magic_link_token.raw).deliver_later
      provider_user.update!(magic_link_token: magic_link_token.encrypted, magic_link_token_sent_at: Time.zone.now)
    end
  end

  def create
    redirect_to new_dfe_path
  end

  def redirect_signed_in_users
    return redirect_to school_path if session.key?(:urn)
  end
end
