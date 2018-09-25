class HiringStaff::TermsAndConditionsController < HiringStaff::BaseController
  skip_before_action :check_terms_and_conditions, only: %i[show update]

  def show
    @terms_and_conditions_form = TermsAndConditionsForm.new
  end

  def update
    @terms_and_conditions_form = TermsAndConditionsForm.new(terms_params)
    if @terms_and_conditions_form.valid?
      current_user.update(accepted_terms_at: Time.zone.now)
      Auditor::Audit.new(current_user, 'user.terms_and_conditions.accept', current_session_id).log
      redirect_to school_path
    else
      render :show
    end
  end

  private

  def terms_params
    params.require(:terms_and_conditions_form).permit(:terms)
  end
end
