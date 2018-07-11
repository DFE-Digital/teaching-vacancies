class HiringStaff::SignIn::Dfe::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create callback]
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    permissions = TeacherVacancyAuthorisation::Permissions.new
    permissions.authorise(identifier)

    if permissions.school_urn.present?
      session.update(session_id: oid)
      session.update(urn: permissions.school_urn)
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

  private def identifier
    auth_hash['uid']
  end
end
