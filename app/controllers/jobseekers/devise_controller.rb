class Jobseekers::DeviseController < ApplicationController
  protected

  def after_sign_out_path_for(_resource)
    new_jobseeker_session_path
  end

  private

  def remove_devise_flash!
    flash.discard(:alert) if flash[:alert].present?
    flash.discard(:notice) if flash[:notice].present?
  end
end
