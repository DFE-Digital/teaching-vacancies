class Jobseekers::JobApplications::QualificationsController < Jobseekers::BaseController
  helper_method :back_path, :form, :job_application, :qualification

  def submit_category
    if params[:commit] == t("buttons.cancel")
      redirect_to back_path
    elsif form.valid?
      redirect_to new_jobseekers_job_application_qualification_path(qualification_params)
    else
      render :select_category
    end
  end

  def create
    if params[:commit] == t("buttons.cancel")
      redirect_to back_path
    elsif form.valid?
      job_application.qualifications.create(qualification_params)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    if params[:commit] == t("buttons.cancel")
      redirect_to back_path
    elsif form.valid?
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
    @form ||= action_name == "select_category" ? form_class.new : form_class.new(qualification_params)
  end

  def form_attributes
    case action_name
    when "new"
      {}
    when "edit"
      qualification.slice(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year)
    when "create", "update"
      qualification_params
    end
  end

  def qualification_params
    form_param_key = form_class.to_s.underscore.tr("/", "_").to_sym
    case action_name
    when "new", "select_category", "submit_category"
      (params[form_param_key] || params).permit(:category)
    when "create", "edit", "update"
      params.require(form_param_key)
            .permit(:category, :finished_studying, :finished_studying_details, :grade, :institution, :name, :subject, :year)
    end
  end

  def form_class
    name = if %w[select_category submit_category].include?(action_name)
             "CategoryForm"
           else
             case params[:category]
             when "gcse", "a_level", "as_level"
               "Secondary::CommonForm"
             when "other_secondary"
               "Secondary::OtherForm"
             when "undergraduate", "postgraduate"
               "DegreeForm"
             when "other"
               "OtherForm"
             end
           end
    "Jobseekers::JobApplication::Details::Qualifications::#{name}".constantize
  end

  def back_path
    @back_path ||= jobseekers_job_application_build_path(job_application, :qualifications)
  end

  def qualification
    @qualification ||= job_application.qualifications.find(params[:id])
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end
end
