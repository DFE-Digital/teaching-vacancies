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
    binding.pry # hi, you are creating the session! NOT expecting this from post logout redirect.
    Rails.logger.warn("Hiring staff signed in: #{user_id}")
    audit_successful_authentication

    perform_dfe_sign_in_authorisation
  end

  private

  def not_authorised
    audit_failed_authorisation
    Rails.logger.warn("Hiring staff not authorised: #{user_id} for school: #{school_urn}")

    @identifier = identifier
    render 'user-not-authorised'
  end

  def update_session(authorisation_permissions)
    session.update(session_id: user_id, urn: school_urn, multiple_schools: authorisation_permissions.many_schools?)
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
    authorisation = Authorisation.new(organisation_id: organisation_id, user_id: user_id)
    authorisation.call
    check_authorisation(authorisation)
  end

  def check_authorisation(authorisation_permissions)
    if authorisation_permissions.authorised?
      update_session(authorisation_permissions)
      current_user.update(email: identifier)
      redirect_to school_path
    else
      not_authorised
    end
  end
end
