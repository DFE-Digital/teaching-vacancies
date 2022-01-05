class Publishers::Vacancies::ExpiredFeedbacksController < Publishers::Vacancies::BaseController
  skip_before_action :authenticate_publisher!, :check_terms_and_conditions

  helper_method :vacancy

  def new
    @feedback_form = Publishers::JobListing::ExpiredFeedbackForm.new
  end

  def create
    @feedback_form = Publishers::JobListing::ExpiredFeedbackForm.new(feedback_form_params)

    if @feedback_form.valid?
      vacancy.update(feedback_form_params)
      redirect_to submitted_organisation_job_expired_feedback_path
    else
      render :new
    end
  end

  private

  def feedback_form_params
    (params[:publishers_job_listing_expired_feedback_form] || params).permit(:hired_status, :listed_elsewhere)
  end

  def vacancy
    @vacancy ||= Vacancy.find_signed(params[:job_id])
  end
end
