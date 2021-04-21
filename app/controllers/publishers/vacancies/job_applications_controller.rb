class Publishers::Vacancies::JobApplicationsController < Publishers::Vacancies::BaseController
  include QualificationFormConcerns

  helper_method :form, :job_application, :job_applications, :qualification_form_param_key, :sort, :sort_form, :vacancy

  def reject
    raise ActionController::RoutingError, "Cannot reject a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?
  end

  def shortlist
    raise ActionController::RoutingError, "Cannot shortlist a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?
  end

  def show
    raise ActionController::RoutingError, "Cannot view a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?
  end

  def update_status
    raise ActionController::RoutingError, "Cannot shortlist or reject a draft or withdrawn application" if
      job_application.draft? || job_application.withdrawn?

    job_application.update(form_params.merge(status: status))
    Jobseekers::JobApplicationMailer.send("application_#{status}".to_sym, job_application).deliver_now
    # TODO: Update redirect when job applications index page exists (and update request/system specs)
    redirect_to organisation_jobs_path,
                success: t(".#{status}", name: "#{job_application.first_name} #{job_application.last_name}")
  end

  private

  def job_applications
    @job_applications ||= vacancy.job_applications.not_draft.order(sort.column => sort.order)
  end

  def form
    @form ||= Publishers::JobApplication::UpdateStatusForm.new
  end

  def form_params
    params.require(:publishers_job_application_update_status_form).permit(:further_instructions, :rejection_reasons)
  end

  def job_application
    @job_application ||= vacancy.job_applications.find(params[:job_application_id] || params[:id])
  end

  def status
    case params[:commit]
    when t("buttons.shortlist")
      "shortlisted"
    when t("buttons.confirm_rejection")
      "unsuccessful"
    end
  end

  def sort
    @sort ||= Publishers::JobApplicationSort.new.update(column: params[:sort_column])
  end

  def sort_form
    @sort_form ||= SortForm.new(sort.column)
  end

  def vacancy
    @vacancy ||= current_organisation.all_vacancies.listed.find(params[:job_id])
  end
end
