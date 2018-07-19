class HiringStaff::SignIn::Azure::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create new failure]
  skip_before_action :verify_authenticity_token, only: %i[create new]

  def new
    # Defined by Azure AD strategy: https://github.com/AzureAD/omniauth-azure-activedirectory#usage
    redirect_to '/auth/azureactivedirectory'
  end

  def create
    permissions = TeacherVacancyAuthorisation::Permissions.new
    permissions.authorise(identifier)
    Auditor::Audit.new(nil, 'azure.authentication.success', current_session_id).log_without_association

    if permissions.school_urn.present?
      update_session(permissions.school_urn)
      redirect_to school_path
    else
      Auditor::Audit.new(nil, 'azure.authorisation.failure', current_session_id).log_without_association
      redirect_to page_path('user-not-authorised')
    end
  end

  def failure
    Auditor::Audit.new(nil, 'azure.authentication.failure', current_session_id).log_without_association
    Rollbar.log('error', 'Sign in provider returned a failure')
    render html: I18n.t('errors.sign_in.failure')
  end

  private

  def update_session(school_urn)
    session.update(session_id: oid, urn: school_urn)
    Auditor::Audit.new(current_school, 'azure.authorisation.success', current_session_id).log
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def oid
    auth_hash['extra']['raw_info']['id_token_claims']['oid']
  end

  def identifier
    auth_hash['info']['name']
  end
end
