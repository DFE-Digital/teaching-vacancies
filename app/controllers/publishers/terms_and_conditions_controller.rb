class Publishers::TermsAndConditionsController < Publishers::BaseController
  skip_before_action :check_terms_and_conditions, only: %i[show update]

  def show
    @terms_and_conditions_form = Publishers::TermsAndConditionsForm.new
  end

  def update
    @terms_and_conditions_form = Publishers::TermsAndConditionsForm.new(terms_params)
    if @terms_and_conditions_form.valid?
      current_publisher.update(accepted_terms_at: Time.current)
      redirect_to organisation_path
    else
      render :show
    end
  end

  private

  def terms_params
    (params[:publishers_terms_and_conditions_form] || params).permit(:terms)
  end
end
