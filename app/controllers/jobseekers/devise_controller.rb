class Jobseekers::DeviseController < ApplicationController
protected

  def after_sign_out_path_for(_resource)
    new_jobseeker_session_path
  end

private

  def replace_devise_notice_flash_with_success!
    flash[:success] = flash.discard(:notice) if flash[:notice].present?
  end

  def remove_devise_flash!
    flash.discard(:notice) if flash[:notice].present?
    flash.discard(:success) if flash[:success].present?
  end
end
