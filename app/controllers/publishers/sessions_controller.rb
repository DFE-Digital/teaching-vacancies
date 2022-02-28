class Publishers::SessionsController < Devise::SessionsController
  include ReturnPathTracking::Helpers

  def new
    redirect_to new_publishers_login_key_path if AuthenticationFallback.enabled?

    if (login_failure = params[:login_failure])
      flash.now[:alert] = t("devise.failure.#{login_failure}")
    end

    store_return_location(publisher_root_path, scope: :publisher) unless redirected?
  end

  def create
    publisher = Publisher.find(session[:publisher_id])

    if publisher.organisations.exists?(id: params[:organisation_id])
      sign_in_publisher!(publisher)
      sign_out_except(:publisher)

      trigger_publisher_sign_in_event(:success, :email)
      redirect_to organisation_path
    else
      trigger_publisher_sign_in_event(:failure, :email, publisher.oid)
      redirect_to new_publisher_session_path, notice: t(".not_authorised")
    end
  end

  def destroy
    clear_extra_publisher_session_entries
    super
  end

  private

  def sign_in_publisher!(publisher)
    sign_in(publisher)
    session.update(publisher_organisation_id: params[:organisation_id])
  end
end
