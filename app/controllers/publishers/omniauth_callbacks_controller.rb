class Publishers::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :dfe

  def new
    # This is defined by the class name of our Omniauth strategy
    redirect_to "/auth/dfe"
  end

  def dfe
    authorisation = Authorisation.new(organisation_id: organisation_id, user_id: user_id).call
    organisation = organisation_from_request

    if authorisation.authorised? && organisation
      sign_in_publisher(organisation)
      trigger_publisher_sign_in_event(:success, :dsi)
      redirect_to after_sign_in_path_for(:publisher)
    else
      trigger_publisher_sign_in_event(:failure, :dsi, user_id)
      render "not_authorised", locals: { email: auth_hash["info"]["email"] }
    end
  end

  def failure
    omniauth_error = request.respond_to?(:get_header) ? request.get_header("omniauth.error") : request.env["omniauth.error"]
    Rollbar.error(omniauth_error, strategy: failed_strategy.name)
    Rails.logger.error("DSI failure - strategy: #{failed_strategy.name}, reason: #{omniauth_error.inspect}")

    redirect_to new_publisher_session_path, warning: t(".message")
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
    case auth_hash.dig("extra", "raw_info", "organisation", "category", "id")
    when "001"
      School.find_by!(urn: auth_hash.dig("extra", "raw_info", "organisation", "urn"))
    when "002"
      SchoolGroup.find_by!(local_authority_code: auth_hash.dig("extra", "raw_info", "organisation", "establishmentNumber"))
    when "010"
      SchoolGroup.find_by!(uid: auth_hash.dig("extra", "raw_info", "organisation", "uid"))
    end
  end

  def sign_in_publisher(organisation)
    publisher = Publisher.find_or_create_by(oid: user_id)
    publisher.update(email: auth_hash["info"]["email"],
                     given_name: auth_hash["info"]["first_name"],
                     family_name: auth_hash["info"]["last_name"])
    OrganisationPublisher.find_or_create_by(organisation_id: organisation.id, publisher_id: publisher.id)

    sign_in(publisher)
    sign_out(:jobseeker)
    session.update(publisher_dsi_token: id_token, publisher_organisation_id: organisation.id)
    use_school_group_if_available(publisher, organisation)
  end

  def use_school_group_if_available(publisher, organisation)
    return unless organisation.school?

    publisher_organisation = publisher.organisations.school_groups.find { |school_group| school_group.schools.include?(organisation) }
    session.update(publisher_organisation_id: publisher_organisation.id) if publisher_organisation
  end
end
