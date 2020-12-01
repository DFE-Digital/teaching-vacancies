class Publishers::SignIn::Dfe::SessionsController < Publishers::SignIn::BaseSessionsController
  include SignInAuditConcerns

  skip_before_action :check_session, only: %i[create new]
  skip_before_action :check_terms_and_conditions, only: %i[create new destroy]
  skip_before_action :verify_authenticity_token, only: %i[create new destroy]
  before_action :redirect_for_fallback_authentication, only: %i[create new]

  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to "/auth/dfe"
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
    Rails.logger.warn(not_authorised_details)
    audit_failed_authorisation
    @identifier = identifier
    render "user-not-authorised"
  end

  def not_authorised_details
    if school_urn.present?
      "Hiring staff not authorised: #{user_id} for school: #{school_urn}"
    elsif trust_uid.present?
      "Hiring staff not authorised: #{user_id} for trust: #{trust_uid}"
    elsif local_authority_code.present?
      "Hiring staff not authorised: #{user_id} for local authority: #{local_authority_code}"
    else
      "Hiring staff not authorised: #{user_id}"
    end
  end

  def update_session(authorisation_permissions)
    session.update(
      publisher_oid: user_id,
      organisation_urn: school_urn,
      organisation_uid: trust_uid,
      organisation_la_code: local_authority_code,
      publisher_multiple_organisations: authorisation_permissions.many_organisations?,
      publisher_id_token: id_token,
    )
    use_school_group_if_available
    Rails.logger.info(updated_session_details)
    audit_successful_authorisation
  end

  def auth_hash
    request.env["omniauth.auth"]
  end

  def user_id
    auth_hash["uid"]
  end

  def identifier
    auth_hash["info"]["email"]
  end

  def school_urn
    return "" unless user_category == :school

    auth_hash.dig("extra", "raw_info", "organisation", "urn") || ""
  end

  def trust_uid
    return "" unless user_category == :multi_academy_trust

    auth_hash.dig("extra", "raw_info", "organisation", "uid") || ""
  end

  def local_authority_code
    return unless LocalAuthorityAccessFeature.enabled?
    return "" unless user_category == :local_authority

    # All organisations have an establishmentNumber, but we only want this for identifying LAs by.
    auth_hash.dig("extra", "raw_info", "organisation", "establishmentNumber") || ""
  end

  def user_category
    # In organisation['category'], DSI provides an 'id' and a 'name' attribute.
    # The mapping is documented in this table:
    # https://github.com/david-mears-dfe/login.dfe.public-api/blob/patch-1/README.md#organisation-categories
    # I am using the id as I imagine that is more stable than the name.
    case auth_hash.dig("extra", "raw_info", "organisation", "category", "id")
    when "001"
      :school
    when "002"
      :local_authority
    when "010"
      :multi_academy_trust
    end
  end

  def organisation_id
    auth_hash.dig("extra", "raw_info", "organisation", "id")
  end

  def id_token
    auth_hash.dig("credentials", "id_token")
  end

  def perform_dfe_sign_in_authorisation
    authorisation = Authorisation.new(organisation_id: organisation_id, user_id: user_id)
    authorisation.call
    check_authorisation(authorisation)
  end

  def check_authorisation(authorisation_permissions)
    if authorisation_permissions.authorised? && organisation_id_present? && allowed_user?
      update_session(authorisation_permissions)
      update_publisher_last_activity_at
      redirect_to organisation_path
    else
      not_authorised
    end
  end

  def redirect_for_fallback_authentication
    redirect_to new_auth_email_path if AuthenticationFallback.enabled?
  end

  def organisation_id_present?
    school_urn.present? || trust_uid.present? || local_authority_code.present?
  end

  def allowed_user?
    school_urn.present? || trust_uid.present? || (local_authority_code.present? &&
      (Rails.env.staging? || Rails.env.development? || ALLOWED_LOCAL_AUTHORITIES.include?(local_authority_code)))
  end

  def use_school_group_if_available
    user = Publisher.find_by(email: identifier)
    user_trusts = user&.dsi_data&.fetch("trust_uids", [])
    user_local_authorities = user&.dsi_data&.fetch("la_codes", [])
    return unless user_trusts&.any? || user_local_authorities&.any?

    school = School.find_by(urn: school_urn)
    school_group = school&.school_groups&.first
    return unless school_group

    session.update(organisation_urn: "", organisation_uid: school_group.uid) if user_trusts.include?(school_group.uid)
    session.update(organisation_urn: "", organisation_la_code: school_group.local_authority_code) if user_local_authorities.include?(school_group.local_authority_code)
  end
end
