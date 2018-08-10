class HiringStaff::TermsAndConditionsController < HiringStaff::BaseController
  skip_before_action :check_terms_and_conditions, only: %i[show update]

  def show; end

  def update
    if terms_params[:accept] == '1'
      current_user.update(accepted_terms_at: Time.zone.now)
      redirect_to school_path
    else
      flash[:error] = I18n.t('terms_and_conditions.error_message')
      render :show
    end
  end

  private

  def terms_params
    params.require(:terms_and_conditions).permit(:accept)
  end
end
