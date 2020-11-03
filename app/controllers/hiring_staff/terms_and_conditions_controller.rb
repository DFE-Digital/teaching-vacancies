class HiringStaff::TermsAndConditionsController < HiringStaff::BaseController
  skip_before_action :check_terms_and_conditions, only: %i[show update]

  def show
    @terms_and_conditions_form = TermsAndConditionsForm.new
  end

  def update
    @terms_and_conditions_form = TermsAndConditionsForm.new(terms_params)
    if @terms_and_conditions_form.valid?
      current_user.update(accepted_terms_at: Time.zone.now)
      audit_toc_acceptance
      redirect_to organisation_path
    else
      render :show
    end
  end

private

  def terms_params
    (params[:terms_and_conditions_form] || params).permit(:terms)
  end

  def audit_toc_acceptance
    Auditor::Audit.new(current_user, "user.terms_and_conditions.accept", current_session_id).log
  end
end
