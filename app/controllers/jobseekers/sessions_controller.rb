class Jobseekers::SessionsController < Devise::SessionsController
  after_action :replace_devise_notice_flash_with_success!, only: %i[create destroy]
  before_action :sign_out_publisher!, only: %i[create]

  def new
    if [I18n.t("devise.failure.invalid"), I18n.t("devise.failure.not_found_in_database")].include? flash[:alert]
      self.resource = resource_class.new(sign_in_params)
      resource.errors.add(:email, flash[:alert])
      flash.clear
      render :new and return
    else
      super
    end
  end
end
