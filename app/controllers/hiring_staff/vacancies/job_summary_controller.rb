class HiringStaff::Vacancies::JobSummaryController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_vacancy

  def show
    @job_summary_form = JobSummaryForm.new(@vacancy.attributes)
  end

  def update
    @job_summary_form = JobSummaryForm.new(job_summary_form_params)

    if @job_summary_form.valid?
      update_vacancy(job_summary_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_after_validation_and_update
    end

    render :show
  end

  private

  def job_summary_form_params
    (params[:job_summary_form] || params).permit(:job_summary, :about_school)
                                         .merge(completed_step: current_step)
  end

  def redirect_after_validation_and_update
    if params[:commit] == I18n.t('buttons.save_and_continue')
      redirect_to school_job_review_path(@vacancy.id)
    elsif params[:commit] == I18n.t('buttons.update_job')
      redirect_to edit_school_job_path(@vacancy.id), success: I18n.t('messages.jobs.updated')
    elsif params[:commit] == I18n.t('buttons.save_and_return')
      redirect_to_school_draft_jobs(@vacancy)
    end
  end
end
