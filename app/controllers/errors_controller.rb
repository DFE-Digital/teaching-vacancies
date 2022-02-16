class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token,
                     only: %i[not_found unprocessable_entity internal_server_error]

  def unauthorised
    respond_to do |format|
      format.html { render status: :unauthorized }
      format.json { render json: { error: "Not authorised" }, status: :unauthorised }
      format.all { render status: :unauthorised, body: nil }
    end
  end

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
      format.all { render status: :not_found, body: nil }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.json { render json: { error: "Unprocessable entity" }, status: :unprocessable_entity }
    end
  end

  def internal_server_error
    @error_id = Sentry.last_event_id

    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
    end
  end

  def invalid_recaptcha
    @form = params[:form_name]
    Sentry.with_scope do |scope|
      scope.set_tags("form.name": @form)
      Sentry.capture_message("Invalid recaptcha")
    end

    respond_to do |format|
      format.html { render status: :unauthorized }
    end
  end
end
