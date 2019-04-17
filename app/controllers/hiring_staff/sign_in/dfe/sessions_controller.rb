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
    audit_successful_authentication

    authorisation = Authorisation.new(organisation_id: organisation_id, user_id: user_id).call
    if authorisation.authorised?
      update_session
      redirect_to school_path
    else
      not_authorised
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
end
