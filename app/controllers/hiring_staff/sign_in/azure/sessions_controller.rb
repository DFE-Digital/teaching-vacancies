class HiringStaff::SignIn::Azure::SessionsController < HiringStaff::BaseController
  skip_before_action :check_session, only: %i[create show new failure]
  skip_before_action :verify_authenticity_token, only: %i[create new]

  def new
    # Defined by Azure AD strategy: https://github.com/AzureAD/omniauth-azure-activedirectory#usage
    redirect_to '/auth/azureactivedirectory'
  end

  def create
    return set_selected_school if selected_school_urn
    permissions = authorise

    if permissions.many?
      select_school(permissions)
      redirect_to azure_path
    elsif permissions.school_urn.present?
      update_session(permissions.school_urn)
      redirect_to school_path
    else
      Auditor::Audit.new(nil, 'azure.authorisation.failure', current_session_id).log_without_association
      redirect_to page_path('user-not-authorised')
    end
  end

  def show
    tva_permissions = session[:tva_permissions]
    school_urns = tva_permissions.map { |item| item['school_urn'] }
    @schools = School.where('urn in (?)', school_urns)
    render 'hiring_staff/azure/sessions/show'
  end

  def failure
    Auditor::Audit.new(nil, 'azure.authentication.failure', current_session_id).log_without_association
    Rollbar.log('error', 'Sign in provider returned a failure')
    render html: I18n.t('errors.sign_in.failure')
  end

  private

  def update_session(school_urn, session_id = oid)
    session.update(session_id: session_id, urn: school_urn)
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

  def selected_school_urn
    params.present? && params['azure'] ? params.require('azure').permit('urn')['urn'] : false
  end

  def authorise
    Auditor::Audit.new(nil, 'azure.authentication.success', current_session_id).log_without_association
    permissions = TeacherVacancyAuthorisation::Permissions.new
    permissions.authorise(identifier)
    permissions
  end

  def select_school(permissions)
    Auditor::Audit.new(nil, 'azure.authorisation.select_school', current_session_id).log_without_association
    session.update(tva_permissions: permissions.all_permissions, oid: oid)
  end

  def set_selected_school
    update_session(selected_school_urn, oid: session[:oid])
    redirect_to school_path
  end
end
