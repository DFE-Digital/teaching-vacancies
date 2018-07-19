class HiringStaff::Vacancies::FeedbackController < HiringStaff::Vacancies::ApplicationController
  def new
    vacancy = Vacancy.published.find_by!(id: params[:job_id])
    if vacancy.feedback.present?
      return redirect_to school_path, notice: I18n.t('errors.feedback.already_submitted')
    end

    @feedback = Feedback.new
  end

  def create
    vacancy = Vacancy.published.find_by!(id: params[:job_id])
    @feedback = Feedback.create(vacancy: vacancy,
                                rating: feedback_params[:rating],
                                comment: feedback_params[:comment])

    return render 'new' unless @feedback.save
    redirect_to school_path, notice: I18n.t('messages.feedback.submitted')
  end

  private

  def feedback_params
    params.require(:feedback).permit(:rating, :comment)
  end
end
