class HiringStaff::SignIn::Dfe::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create callback]
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

  private def auth_hash
    request.env['omniauth.auth']
  end

  private def oid
    auth_hash['uid']
  end
end
