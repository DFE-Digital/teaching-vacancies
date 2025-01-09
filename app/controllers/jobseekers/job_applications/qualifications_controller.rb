class Jobseekers::JobApplications::QualificationsController < Jobseekers::BaseController
  include Jobseekers::QualificationFormConcerns

  helper_method :back_path, :job_application, :qualification, :qualification_form_param_key

  before_action :set_category_and_form, only: %i[create update]

  def select_category
    @form = Jobseekers::Qualifications::CategoryForm.new
  end

  def submit_category
    @category = category_param
    @form = Jobseekers::Qualifications::CategoryForm.new(submit_category_params)

    if @form.valid?
      redirect_to new_jobseekers_job_application_qualification_path(submit_category_params)
    else
      render :select_category, status: :unprocessable_entity
    end
  end

  def new
    @category = category_param
    @form = category_form_class(@category).new(category: @category)
  end

  def edit
    @category = qualification.category
    edit_attributes = qualification
                        .slice(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year, :qualification_results)
                        .reject { |_, v| v.blank? && v != false }

    @form = category_form_class(@category).new(edit_attributes)
  end

  def create
    if @form.valid?
      job_application.qualifications.create(qualification_params)
      redirect_to back_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @form.valid?
      qualification.update(qualification_params)
      redirect_to back_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    qualification.destroy
    redirect_to back_path, success: t(".success")
  end

  private

  def submit_category_params
    key = ActiveModel::Naming.param_key(Jobseekers::Qualifications::CategoryForm)
    (params[key] || params).permit(:category)
  end

  def qualification_params
    params.require(qualification_form_param_key(@category))
          .permit(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year, qualification_results_attributes: %i[id subject grade awarding_body])
  end

  def set_category_and_form
    @category = action_name.in?(%w[update]) ? qualification.category : category_param
    @form = category_form_class(@category).new(qualification_params)
  end

  def category_param
    params.permit(:category)[:category]
  end

  def back_path
    @back_path ||= jobseekers_job_application_build_path(job_application, :qualifications)
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  def qualification
    @qualification ||= job_application.qualifications.find(params[:id])
  end
end
