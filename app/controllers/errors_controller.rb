class ErrorsController < ApplicationController
  skip_before_action :verify_authenticity_token,
                     only: %i[not_found unprocessable_entity internal_server_error]

  def unauthorised
    respond_to do |format|
      format.html { render status: 401 }
      format.json { render json: { error: 'Not authorised' }, status: 401 }
      format.all { render status: 401, body: nil }
    end
  end

  def not_found
    respond_to do |format|
      format.html { render status: 404 }
      format.json { render json: { error: 'Resource not found' }, status: 404 }
      format.all { render status: 404, body: nil }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render status: 422 }
      format.json { render json: { error: 'Unprocessable entity' }, status: 422 }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: 500 }
      format.json { render json: { error: 'Internal server error' }, status: 500 }
    end
  end
end
