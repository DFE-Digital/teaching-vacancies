class Jobseekers::JobApplications::ReferencesController < Jobseekers::BaseController
  helper_method :back_path, :form, :job_application, :reference

  def create
    if form.valid?
      job_application.references.create(reference_params)
      update_in_progress_steps!(:references)
      redirect_to back_path
    else
      render :new
    end
  end

  def update
    if form.valid?
      reference.update(reference_params)
      redirect_to back_path
    else
      render :edit
    end
  end

  def destroy
    reference.destroy
    redirect_to back_path, success: t(".success")
  end

  private

  def back_path
    @back_path ||= jobseekers_job_application_build_path(job_application, :references)
  end

  def form
    @form ||= Jobseekers::JobApplication::Details::ReferenceForm.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "new"
      {}
    when "edit"
      reference.slice(:name, :job_title, :organisation, :relationship, :email, :phone_number)
    when "create", "update"
      reference_params
    end
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  def reference
    job_application.references.find(params[:id])
  end

  def reference_params
    params.require(:jobseekers_job_application_details_reference_form)
          .permit(:name, :job_title, :organisation, :relationship, :email, :phone_number)
  end
end
