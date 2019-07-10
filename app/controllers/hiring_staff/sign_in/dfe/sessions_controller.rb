class HiringStaff::SignIn::Dfe::SessionsController < HiringStaff::BaseController
  include SignInAuditConcerns

  skip_before_action :check_session, only: %i[create new]
  skip_before_action :check_terms_and_conditions, only: %i[create new]
  skip_before_action :verify_authenticity_token, only: %i[create new]

  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to '/auth/dfe'
  end

  def create
    Rails.logger.warn("Hiring staff signed in: #{user_id}")
    if DfeSignInAuthorisationFeature.enabled?
      perform_dfe_sign_in_authorisation
    else
      perform_non_dfe_sign_in_authorisation
    end
  rescue Authorisation::ExternalServerError => error
    Rollbar.log(:error, error)
    respond_to do |format|
      format.html { render 'errors/external_server_error', status: :server_error }
    end
  end

  private

  def not_authorised
    audit_failed_authorisation
    Rails.logger.warn("Hiring staff not authorised: #{user_id} for school: #{school_urn}")

    @identifier = identifier
    render 'user-not-authorised'
  end

  def update_session
    session.update(session_id: user_id, urn: school_urn)
    audit_successful_authorisation
  end

  def update_non_dsi_session(school_urn, permissions)
    session.update(session_id: user_id, urn: school_urn, multiple_schools: permissions.many?)
    audit_successful_authorisation
  end

  def auth_hash
    request.env['omniauth.auth']
  end

  def user_id
    auth_hash['uid']
  end

  def identifier
    auth_hash['info']['email']
  end

  def school_urn
    auth_hash.dig('extra', 'raw_info', 'organisation', 'urn') || ''
  end

  def organisation_id
    auth_hash.dig('extra', 'raw_info', 'organisation', 'id')
  end

  def perform_dfe_sign_in_authorisation
    audit_successful_authentication

    authorisation = Authorisation.new(organisation_id: organisation_id, user_id: user_id).call
    if authorisation.authorised?
      update_session
      redirect_to school_path
    else
      not_authorised
    end
  end

  def perform_non_dfe_sign_in_authorisation
    permissions = TeacherVacancyAuthorisation::Permissions.new
    permissions.authorise(identifier, school_urn)

    audit_successful_authentication

    if permissions.authorised?
      update_non_dsi_session(permissions.school_urn, permissions)
      redirect_to school_path
    else
      not_authorised
    end
  end
end
