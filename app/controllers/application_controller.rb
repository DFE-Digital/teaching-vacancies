class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, except: :not_found

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found
    respond_to do |format|
      format.html { render 'errors/not_found', status: 404 }
      format.json { render json: { errors: 'Resource not found' }, status: 404 }
      format.all { render status: 404, body: nil }
    end
  end
end
