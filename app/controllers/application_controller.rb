class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: :not_found

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  before_action :authenticate

  def not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: 404 }
      format.json { render json: { errors: 'Resource not found' }, status: 404 }
      format.all { render status: 404, body: nil }
    end
  end

  def authenticate
    return unless Figaro.env.http_user? && Figaro.env.http_pass?
    authenticate_or_request_with_http_basic do |name, password|
      name == Figaro.env.http_user && password == Figaro.env.http_pass
    end
  end
end
