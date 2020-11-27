class Jobseekers::SessionsController < Devise::SessionsController
  after_action :replace_devise_notice_flash_with_success!, only: %i[create destroy]
  before_action :sign_out_publisher!, only: %i[create]
end
