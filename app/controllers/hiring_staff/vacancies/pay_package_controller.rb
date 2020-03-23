class HiringStaff::Vacancies::PayPackageController < HiringStaff::Vacancies::ApplicationController
  before_action :set_vacancy
  before_action :redirect_unless_vacancy

  def show
    @pay_package_form = PayPackageForm.new(@vacancy.attributes)
  end

  def update
    @pay_package_form = PayPackageForm.new(pay_package_form_params)

    if @pay_package_form.valid?
      update_vacancy(pay_package_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_save_and_continue
    end

    render :show
  end

  private

  def pay_package_form_params
    (params[:pay_package_form] || params).permit(:salary, :benefits)
  end

  def next_step
    UploadDocumentsFeature.enabled? ? supporting_documents_school_job_path : candidate_specification_school_job_path
  end

  def redirect_to_next_step_if_save_and_continue
    if params[:commit] == 'Save and continue'
      redirect_to_next_step(@vacancy)
    elsif params[:commit] == 'Update job'
      redirect_to edit_school_job_path(@vacancy.id), success: I18n.t('messages.jobs.updated')
    end
  end
end
