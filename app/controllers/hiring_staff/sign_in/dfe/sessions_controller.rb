class HiringStaff::SignIn::Dfe::SessionsController < HiringStaff::SignIn::BaseSessionsController
  include SignInAuditConcerns

  skip_before_action :check_session, only: %i[create new]
  skip_before_action :check_terms_and_conditions, only: %i[create new destroy]
  skip_before_action :verify_authenticity_token, only: %i[create new destroy]
  before_action :redirect_for_fallback_authentication, only: %i[create new]

  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to '/auth/dfe'
  end

  def create
    Rails.logger.warn("Hiring staff signed in: #{user_id}")
    audit_successful_authentication

    perform_dfe_sign_in_authorisation
  end

  def destroy
    end_session_and_redirect
  end

  private

  def not_authorised
    audit_failed_authorisation
    Rails.logger.warn("Hiring staff not authorised: #{user_id} for school: #{school_urn}")

    @identifier = identifier
    render 'user-not-authorised'
  end

  def update_session(authorisation_permissions)
    session.update(
      session_id: user_id,
      urn: school_urn,
      uid: school_group_uid,
      multiple_organisations: authorisation_permissions.many_organisations?,
      id_token: id_token
    )
    Rails.logger.info("Updated session with URN #{session[:urn]} or UID #{session[:uid]}")
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

  def school_group_uid
    if SchoolGroupJobsFeature.enabled?
      auth_hash.dig('extra', 'raw_info', 'organisation', 'uid') || ''
    end
  end

  def organisation_id
    auth_hash.dig('extra', 'raw_info', 'organisation', 'id')
  end

  def id_token
    auth_hash.dig('credentials', 'id_token')
  end

  def perform_dfe_sign_in_authorisation
    authorisation = Authorisation.new(organisation_id: organisation_id, user_id: user_id)
    authorisation.call
    check_authorisation(authorisation)
  end

  def check_authorisation(authorisation_permissions)
    if authorisation_permissions.authorised? && organisation_id_present
      update_session(authorisation_permissions)
      update_user_last_activity_at
      redirect_to_organisation_path
    else
      not_authorised
    end
  end

  def redirect_for_fallback_authentication
    redirect_to new_auth_email_path if AuthenticationFallback.enabled?
  end

  def organisation_id_present
    school_urn.present? || school_group_uid.present?
  end
end
