class HiringStaff::SignIn::Dfe::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create new]
  skip_before_action :verify_authenticity_token, only: %i[create new]

  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to '/auth/dfe'
  end

  def create
    permissions = TeacherVacancyAuthorisation::Permissions.new
    permissions.authorise(identifier)
    Auditor::Audit.new(nil, 'dfe-sign-in.authentication.success', current_session_id).log_without_association

    if permissions.all_permissions.any?
      school_urn = selected_school_urn || permissions.school_urn
      update_session(school_urn)
      redirect_to school_path
    else
      Auditor::Audit.new(nil, 'dfe-sign-in.authorisation.failure', current_session_id).log_without_association
      redirect_to page_path('user-not-authorised')
    end
  end

  private

  def update_session(school_urn)
    session.update(session_id: oid, urn: school_urn)
    Auditor::Audit.new(current_school, 'dfe-sign-in.authorisation.success', current_session_id).log
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def oid
    auth_hash['uid']
  end

  def identifier
    auth_hash['info']['email']
  end

  def selected_school_urn
    auth_hash.dig('extra', 'raw_info', 'organisation', 'urn')
  end
end
