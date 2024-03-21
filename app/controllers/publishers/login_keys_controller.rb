class Publishers::LoginKeysController < ApplicationController
  EMERGENCY_LOGIN_KEY_DURATION = 10.minutes

  before_action :redirect_signed_in_publishers, only: %i[new create show]
  before_action :redirect_for_dsi_authentication, only: %i[new create show]
  before_action :check_login_key, only: %i[show consume]

  def new
    flash.now[:notice] = t(".notice")
  end

  def create
    publisher = Publisher.find_by(email: params.dig(:publisher, :email).downcase.strip)
    send_login_key(publisher: publisher) if publisher
  end

  def show
    @publisher = Publisher.find(@login_key.publisher_id)

    if @publisher.organisations.none?
      render(partial: "error", locals: { failure: "no_orgs" })
    else
      @form = Publishers::LoginKeys::ChooseOrganisationForm.new
      render(:show)
    end
  end

  def consume
    @publisher = Publisher.find(@login_key.publisher_id)
    @form = Publishers::LoginKeys::ChooseOrganisationForm.new(choose_organisation_form_params)

    if @form.valid?
      org = Organisation.find(@form.organisation)
      @login_key.destroy
      session.update(publisher_id: @publisher.id)
      redirect_to create_publisher_session_path(organisation_id: org.id)
    else
      render(:show)
    end
  end

  private

  def choose_organisation_form_params
    (params[:publishers_login_keys_choose_organisation_form] || params).permit(:organisation)
  end

  def check_login_key
    @login_key = EmergencyLoginKey.find_by(id: params[:id])
    failure = if @login_key.nil?
                "no_key"
              elsif @login_key.expired?
                "expired"
              end

    (render(:error, locals: { failure: }) and return) if failure.present?
  end

  def redirect_signed_in_publishers
    return unless publisher_signed_in? && current_organisation.present?

    redirect_to publisher_root_path
  end

  def redirect_for_dsi_authentication
    return if AuthenticationFallback.enabled?

    redirect_to new_publisher_session_path
  end

  def send_login_key(publisher:)
    Publishers::AuthenticationFallbackMailer.sign_in_fallback(
      login_key_id: generate_login_key(publisher: publisher).id,
      publisher: publisher,
    ).deliver_later
  end

  def generate_login_key(publisher:)
    publisher.emergency_login_keys.create(not_valid_after: Time.current + EMERGENCY_LOGIN_KEY_DURATION)
  end
end
