class Jobseekers::JobApplications::DetailsController < Jobseekers::ApplicationController
  helper_method :back_link_path, :build_step, :detail, :form, :job_application

  def create
    if form.valid?
      job_application.job_application_details.create(details_type: build_step, data: detail_params)
      if params[:commit] == t("jobseekers.job_applications.details.form.#{build_step}.add_another")
        redirect_to new_jobseekers_job_application_build_detail_path(job_application, build_step)
      else
        redirect_to back_link_path
      end
    else
      render :new
    end
  end

  def update
    if form.valid?
      detail.update(data: detail.data.merge(detail_params))
      redirect_to back_link_path
    else
      render :edit
    end
  end

  def destroy
    detail.destroy
    redirect_to back_link_path, success: t("messages.jobseekers.job_applications.#{build_step}.deleted")
  end

  private

  def back_link_path
    @back_link_path ||= jobseekers_job_application_build_path(job_application, build_step)
  end

  def build_step
    @build_step ||= params[:build_id]
  end

  def detail
    @detail ||= job_application.job_application_details.find(params[:id])
  end

  def detail_params
    case build_step
    when "references"
      reference_params
    end
  end

  def form
    case build_step
    when "references"
      @form ||= Jobseekers::JobApplication::Details::ReferenceForm.new(form_attributes)
    end
  end

  def form_attributes
    case action_name
    when "new"
      {}
    when "edit"
      detail.data
    when "create", "update"
      detail_params
    end
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end

  def reference_params
    params.require(:jobseekers_job_application_details_reference_form)
          .permit(:name, :job_title, :organisation, :relationship_to_applicant, :email_address, :phone_number)
  end
end
