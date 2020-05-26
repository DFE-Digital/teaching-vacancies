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
      return redirect_to_next_step_if_save_and_continue(@vacancy.id)
    end

    render :show
  end

  private

  def pay_package_form_params
    params.require(:pay_package_form).permit(:state, :salary, :benefits).merge(completed_step: current_step)
  end

  def next_step
    school_job_supporting_documents_path(@vacancy.id)
  end
end
