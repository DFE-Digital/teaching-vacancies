class Jobseekers::EmailPreferencesController < Jobseekers::BaseController
  FORM_ATTRIBUTES = %i[email_opt_out email_opt_out_reason email_opt_out_comment].freeze

  def edit
    @form = Jobseekers::EmailPreferencesForm.new(current_jobseeker.slice(*FORM_ATTRIBUTES))
  end

  def update
    @form = Jobseekers::EmailPreferencesForm.new(email_preferences_params)

    if @form.valid?
      current_jobseeker.update!(email_preferences_params)

      redirect_to jobseekers_account_path, success: t(".success")
    else
      render :edit
    end
  end

  private

  def email_preferences_params
    params.require(:jobseekers_email_preferences_form).permit(*FORM_ATTRIBUTES)
  end
end
