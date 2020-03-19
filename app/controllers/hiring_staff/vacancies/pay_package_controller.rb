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
      return redirect_to_next_step(@vacancy)
    end

    render :show
  end

  private

  def pay_package_form_params
    (params[:pay_package_form] || params).permit(:salary)
  end

  def next_step
    UploadDocumentsFeature.enabled? ? supporting_documents_school_job_path : candidate_specification_school_job_path
  end
end
