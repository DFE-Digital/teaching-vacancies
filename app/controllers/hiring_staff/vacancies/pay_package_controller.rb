class HiringStaff::Vacancies::PayPackageController < HiringStaff::Vacancies::ApplicationController
  before_action :redirect_unless_vacancy
  before_action only: %i[update] do
    save_vacancy_as_draft_if_save_and_return_later(pay_package_form_params, @vacancy)
  end

  def show
    @pay_package_form = PayPackageForm.new(@vacancy.attributes)
  end

  def update
    @pay_package_form = PayPackageForm.new(pay_package_form_params)

    if @pay_package_form.valid?
      update_vacancy(pay_package_form_params, @vacancy)
      update_google_index(@vacancy) if @vacancy.listed?
      return redirect_to_next_step_if_continue(@vacancy.id, @vacancy.job_title)
    end

    render :show
  end

  private

  def pay_package_form_params
    params.require(:pay_package_form).permit(:state, :salary, :benefits).merge(completed_step: current_step)
  end

  def next_step
    school_job_important_dates_path(@vacancy.id)
  end
end
