class Jobseekers::SessionsController < Devise::SessionsController
  after_action :replace_devise_notice_flash_with_success!, only: %i[create destroy]
  before_action :sign_out_publisher!, only: %i[create]

  def new
    @sign_in_form = JobseekerSignInForm.new(flash[:alert], sign_in_params)
    if params[:action] == "create" && @sign_in_form.invalid?
      flash.clear
      render :new
    else
      super
    end
  end
end
