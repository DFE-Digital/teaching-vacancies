class Jobseekers::UnlocksController < Devise::UnlocksController
  after_action :replace_devise_notice_flash_with_success!, only: %i[show]
end
