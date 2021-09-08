class Jobseekers::JobApplications::BuildController < Jobseekers::BaseController
  include Wicked::Wizard
  include Jobseekers::Wizardable
  include QualificationFormConcerns

  steps :personal_details, :professional_status, :qualifications, :employment_history, :personal_statement, :references,
        :equal_opportunities, :ask_for_support, :declarations

  helper_method :back_path, :employments, :form, :job_application, :qualification_form_param_key, :redirect_to_review?, :vacancy

  def show
    render_wizard
  end

  def update
    if form.valid?
      job_application.update(update_params)

      return redirect_to finish_wizard_path, success: t("messages.jobseekers.job_applications.saved") if redirect_to_review?

      render_wizard job_application
    else
      render_wizard
    end
  end

  private

  def back_path
    @back_path ||= if referrer_is_finish_wizard_path?
                     finish_wizard_path
                   elsif step == :personal_details
                     new_jobseekers_job_job_application_path(vacancy.id)
                   else
                     previous_wizard_path
                   end
  end

  def form
    @form ||= "Jobseekers::JobApplication::#{step.to_s.camelize}Form".constantize.new(form_attributes)
  end

  def form_attributes
    case action_name
    when "show"
      job_application.slice(*send("#{step}_fields"))
    when "update"
      form_params
    end
  end

  def form_params
    (params["jobseekers_job_application_#{step}_form".to_sym] || params).permit(*send("#{step}_fields"))
  end

  def finish_wizard_path
    jobseekers_job_application_review_path(job_application)
  end

  def employments
    @employments ||= job_application.employments.order(:started_on)
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  def redirect_to_review?
    current_jobseeker.job_applications.not_draft.any? || referrer_is_finish_wizard_path?
  end

  def referrer_is_finish_wizard_path?
    URI(request.referrer || "").path == finish_wizard_path || URI(params[:origin] || "").path == finish_wizard_path
  end

  def update_params
    form_params.merge(
      completed_steps: job_application.completed_steps.append(step.to_s).uniq,
      in_progress_steps: job_application.in_progress_steps.delete_if { |in_progress_step| in_progress_step == step.to_s },
    )
  end

  def vacancy
    @vacancy ||= job_application.vacancy
  end
end
