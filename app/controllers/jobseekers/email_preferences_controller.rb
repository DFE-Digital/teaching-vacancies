class Jobseekers::EmailPreferencesController < Jobseekers::BaseController
  def edit
    @form = Jobseekers::EmailPreferencesForm.new(current_jobseeker)
  end

  def update
    @form = Jobseekers::EmailPreferencesForm.new(current_jobseeker, email_preferences_params)
    
    if @form.valid?
      current_jobseeker.update(
        email_opt_out: @form.email_opt_out == "true",
        email_opt_out_reason: @form.email_opt_out == "true" ? @form.email_opt_out_reason : nil,
        email_opt_out_comment: @form.email_opt_out == "true" ? @form.email_opt_out_comment : nil,
        email_opt_out_at: @form.email_opt_out == "true" ? Time.current : nil
      )
      
      redirect_to jobseekers_account_path, success: t(".success")
    else
      render :edit
    end
  end

  private

  def email_preferences_params
    params.require(:jobseekers_email_preferences_form).permit(
      :email_opt_out,
      :email_opt_out_reason,
      :email_opt_out_comment
    )
  end
end