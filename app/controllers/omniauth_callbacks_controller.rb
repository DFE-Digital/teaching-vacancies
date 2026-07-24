require "hash_shape"

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :dfe
  prepend_before_action :set_sentry_auth_context, only: :dfe

  class OrganisationCategoryNotFound < StandardError; end
  rescue_from OrganisationCategoryNotFound, with: :unknown_organisation_category

  class EstablishmentTypeNotSupported < StandardError; end
  rescue_from EstablishmentTypeNotSupported, with: :unsupported_establishment_type

  class EstablishmentNotRegistered < StandardError; end
  rescue_from EstablishmentNotRegistered, with: :establishment_not_registered

  def dfe
    return render "pending_approval" unless org_data&.key?("id")

    authorisation = Publishers::DfeSignIn::Authorisation.new(organisation_id: organisation_id, user_id: user_id)

    if authorisation.authorised_support_user?
      sign_in_support_user
      redirect_to after_sign_in_path_for(:support_user)
    elsif authorisation.authorised_publisher?
      sign_in_publisher(organisation_from_request)
      trigger_successful_publisher_sign_in_event(:dsi)
      redirect_to after_sign_in_path_for(:publisher)
    else
      trigger_failed_dsi_sign_in_event(:dsi, user_id)
      render "not_authorised", locals: { email: auth_hash["info"]["email"] }
    end
  end

  def failure
    report_omniauth_error
    redirect_to new_publisher_session_path, warning: t(".message")
  end

  def unknown_organisation_category(exception)
    @org_name = org_data.fetch("name")
    @org_type = org_data.dig("category", "name")

    render_unsupported_organisation(
      exception,
      template: "unknown_organisation_category",
    )
  end

  def unsupported_establishment_type(exception)
    @org_name = org_data.fetch("name")
    @org_type = org_data.dig("type", "name")

    render_unsupported_organisation(
      exception,
      template: "unsupported_establishment_type",
    )
  end

  def establishment_not_registered(exception)
    @org_name = org_data.fetch("name")
    render_unsupported_organisation(
      exception,
      template: "unregistered_establishment",
    )
  end

  private

  # Attaches the DSI auth data to the Sentry scope so that any error reported during the sign in
  # flow (whether captured explicitly or auto-captured as an unhandled exception) carries the
  # organisation payload and the full key structure of the auth hash.
  def set_sentry_auth_context
    return if auth_hash.blank?

    Sentry.configure_scope do |scope|
      scope.set_context(
        "DSI auth data",
        {
          dsi_user_id: user_id,
          organisation: org_data,
          auth_hash_shape: HashShape.of(auth_hash),
        },
      )
    end
  end

  def render_unsupported_organisation(exception, template:)
    # The DSI auth context is already attached to the Sentry scope by `set_sentry_auth_context`.
    Sentry.capture_exception(exception)

    render template, status: :forbidden
  end

  def find_school(urn)
    type_id = org_data.dig("type", "id")
    raise EstablishmentTypeNotSupported, "Organisation type ID `#{type_id}`" if Publishers::DfeSignIn::OrgIdMappings.out_of_scope_type?(type_id)

    School.kept.find_by(urn: urn).presence || raise(EstablishmentNotRegistered, "Organisation urn #{urn} not enabled")
  end

  def auth_hash
    request.env["omniauth.auth"]
  end

  def user_id
    auth_hash["uid"]
  end

  def organisation_id
    org_data.fetch("id")
  end

  def id_token
    auth_hash.dig("credentials", "id_token")
  end

  def org_data
    auth_hash.dig("extra", "raw_info", "organisation")
  end

  def organisation_from_request
    # https://github.com/DFE-Digital/login.dfe.public-api#how-do-ids-map-to-categories-and-types
    case (cat_id = org_data.dig("category", "id"))
    when Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:single_establishment]
      find_school org_data.fetch("urn")
    when Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:local_authority]
      SchoolGroup.find_by!(local_authority_code: org_data.fetch("establishmentNumber"))
    when Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:multi_academy_trust]
      SchoolGroup.find_by!(uid: org_data.fetch("uid"))
    when Publishers::DfeSignIn::OrgIdMappings::CATEGORIES[:single_academy_trust]
      # If the user is trying to sign in as a single-academy trust, try and find the school
      # contained within the trust and use that instead
      uid = auth_hash.dig("extra", "raw_info", "organisation", "uid")
      contained_school = School.find_by(
        "gias_data->>'TrustSchoolFlag (code)' = ? AND gias_data->>'Trusts (code)' = ?",
        "5", # "Supported by a single-academy trust"
        uid,
      )

      contained_school || raise("Could not find a school contained in SAT (UID #{uid})")
    else
      raise OrganisationCategoryNotFound, "Organisation category ID `#{cat_id}`"
    end
  end

  def sign_in_publisher(organisation)
    publisher = find_or_create(Publisher)

    OrganisationPublisher.find_or_create_by(organisation_id: organisation.id, publisher_id: publisher.id)

    sign_in(publisher)
    sign_out_except(:publisher)
    session.update(publisher_dsi_token: id_token, publisher_organisation_id: organisation.id)
    use_school_group_if_available(publisher, organisation)
  end

  def sign_in_support_user
    support_user = find_or_create(SupportUser)
    sign_in(support_user)
    sign_out_except(:support_user)
  end

  def find_or_create(klass)
    klass.find_or_create_by(oid: user_id).tap do |record|
      info = auth_hash.fetch("info")
      record.update(
        email: info["email"],
        given_name: info["first_name"],
        family_name: info["last_name"],
      )
    end
  end

  def use_school_group_if_available(publisher, organisation)
    return unless organisation.school?

    publisher_organisation = publisher.organisations.school_groups.find { |school_group| school_group.schools.include?(organisation) }
    session.update(publisher_organisation_id: publisher_organisation.id) if publisher_organisation
  end

  def report_omniauth_error
    omniauth_error = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]

    # This error means DSI has redirected the user back to us after the user's session has expired
    # on _their_ end - it's an expected occurrence and not an error we want to track.
    return if omniauth_error.respond_to?(:error) && omniauth_error.error.to_s == "sessionexpired"

    Sentry.with_scope do |scope|
      scope.set_tags(
        "omniauth.error": omniauth_error,
        "omniauth.failed_strategy": failed_strategy.name,
      )

      if omniauth_error.is_a?(OmniAuth::Strategies::OpenIDConnect::CallbackError)
        scope.set_tags(
          "omniauth.error_type": omniauth_error.error,
          "omniauth.error_reason": omniauth_error.error_reason,
        )
      end

      Sentry.capture_message("User failed to sign in with DfE Sign In", level: :warning)
    end
  end
end
