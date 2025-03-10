module Jobseekers
  class EmailPreferencesController < BaseController
    before_action :set_model

    def edit; end

    def update
      if @model.update(email_preferences_params)
        redirect_to jobseekers_account_path, success: t(".success")
      else
        render :edit
      end
    end

    private

    def set_model
      @model = current_jobseeker
    end

    def email_preferences_params
      params.require(:jobseekers_email_preferences_form).permit(:email_opt_out, :email_opt_out_reason, :email_opt_out_comment)
    end
  end
end
