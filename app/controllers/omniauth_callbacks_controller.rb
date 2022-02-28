class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :dfe

  def dfe
    authorisation = Authorisation.new(organisation_id: organisation_id, user_id: user_id)

    if authorisation.authorised_support_user?
      sign_in_support_user
      trigger_successful_support_user_sign_in_event(:dsi)
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
    omniauth_error = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]
    Sentry.with_scope do |scope|
      scope.set_tags(
        "omniauth.error": omniauth_error,
        "omniauth.failed_strategy": failed_strategy.name,
      )
      Sentry.capture_message("Omniauth error")
    end

    redirect_to new_publisher_session_path, warning: t(".message")
  end

  def fake
    raise "Not permitted outside development" unless Rails.env.development?

    support_user = SupportUser.last
    sign_in(support_user)
    sign_out_except(:support_user)

    redirect_to after_sign_in_path_for(:support_user)
  end

  private

  def auth_hash
    request.env["omniauth.auth"]
  end

  def user_id
    auth_hash["uid"]
  end

  def organisation_id
    auth_hash.dig("extra", "raw_info", "organisation", "id")
  end

  def id_token
    auth_hash.dig("credentials", "id_token")
  end

  def organisation_from_request
    # https://github.com/DFE-Digital/login.dfe.public-api#how-do-ids-map-to-categories-and-types
    case (cat_id = auth_hash.dig("extra", "raw_info", "organisation", "category", "id"))
    when "001"
      School.find_by!(urn: auth_hash.dig("extra", "raw_info", "organisation", "urn"))
    when "002"
      SchoolGroup.find_by!(local_authority_code: auth_hash.dig("extra", "raw_info", "organisation", "establishmentNumber"))
    when "010"
      SchoolGroup.find_by!(uid: auth_hash.dig("extra", "raw_info", "organisation", "uid"))
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

  class OrganisationCategoryNotFound < StandardError; end
end
