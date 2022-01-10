class Jobseekers::JobApplications::QualificationsController < Jobseekers::BaseController
  include QualificationFormConcerns

  helper_method :back_path, :category, :form, :job_application, :qualification, :secondary?

  def submit_category
    if form.valid?
      redirect_to new_jobseekers_job_application_qualification_path(qualification_params)
    else
      render :select_category
    end
  end

  def create
    if form.valid?
      job_application.qualifications.create(qualification_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    if form.valid?
      qualification.update(qualification_params)
      redirect_to back_path
    else
      render :edit
    end
  end

  def destroy
    qualification.destroy
    redirect_to back_path, success: t(".success")
  end

  private

  def form
    @form ||= category_form_class(category).new(form_attributes)
  end

  def form_attributes
    case action_name
    when "new"
      { category: }
    when "select_category"
      {}
    when "edit"
      qualification
        .slice(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year, :qualification_results)
        .reject { |_, v| v.blank? && v != false }
    when "create", "update", "submit_category"
      qualification_params
    end
  end

  def qualification_params
    case action_name
    when "new", "select_category", "submit_category"
      (params[qualification_form_param_key(category)] || params).permit(:category)
    when "create", "edit", "update"
      params.require(qualification_form_param_key(category))
            .permit(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year, qualification_results_attributes: %i[id subject grade])
    end
  end

  def category
    @category ||= action_name.in?(%w[edit update]) ? qualification.category : category_param
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

  def secondary?
    category.in?(Qualification::SECONDARY_QUALIFICATIONS)
  end
end
