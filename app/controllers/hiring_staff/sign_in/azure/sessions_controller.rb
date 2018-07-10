class HiringStaff::SignIn::Azure::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create failure]
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    permission = Permission.new(identifier: oid)

    if permission.valid?
      session.update(session_id: oid)
      session.update(urn: permission.school_urn)
      redirect_to school_path
    else
      redirect_to root_path, notice: I18n.t('errors.sign_in.unauthorised')
    end
  end

  def failure
    Rollbar.log('error', 'Sign in provider returned a failure')
    render html: I18n.t('errors.sign_in.failure')
  end

  private def auth_hash
    request.env['omniauth.auth']
  end

  private def oid
    auth_hash['extra']['raw_info']['id_token_claims']['oid']
  end
end
