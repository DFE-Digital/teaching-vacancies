class HiringStaff::Vacancies::PayPackageController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_vacancy

  def show
    @pay_package_form = PayPackageForm.new(@vacancy.attributes)
  end

  def update
    @pay_package_form = PayPackageForm.new(pay_package_form_params)

    if @pay_package_form.valid?
      update_vacancy(pay_package_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_after_validation_and_update
    end

    render :show
  end

  private

  def pay_package_form_params
    (params[:pay_package_form] || params).permit(:salary, :benefits).merge(completed_step: current_step)
  end

  def next_step
    supporting_documents_school_job_path
  end

  def redirect_after_validation_and_update
    if params[:commit] == I18n.t('buttons.save_and_continue')
      redirect_to_next_step(@vacancy)
    elsif params[:commit] == I18n.t('buttons.update_job')
      redirect_to edit_school_job_path(@vacancy.id), success: I18n.t('messages.jobs.updated')
    elsif params[:commit] == I18n.t('buttons.save_and_return')
      redirect_to_school_draft_jobs(@vacancy)
    end
  end
end
