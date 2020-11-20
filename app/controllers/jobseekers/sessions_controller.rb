class Jobseekers::SessionsController < Devise::SessionsController
  after_action :replace_devise_notice_flash_with_success!, only: %i[create destroy]

private

  def replace_devise_notice_flash_with_success!
    # We want to display Devise notices for sessions (but not alerts) as success messages instead
    flash[:success] = flash.discard(:notice)
  end
end
