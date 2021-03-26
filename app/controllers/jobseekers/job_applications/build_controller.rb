class Jobseekers::JobApplications::BuildController < Jobseekers::BaseController
  include Wicked::Wizard
  include Jobseekers::Wizardable

  steps :personal_details, :professional_status, :employment_history, :personal_statement, :references,
        :equal_opportunities, :ask_for_support, :declarations

  helper_method :back_path, :employment_history_info, :form, :job_application, :process_steps, :reference_info, :vacancy

  def show
    render_wizard
  end

  def update
    if params[:commit] == t("buttons.save_and_come_back")
      job_application.update(form_params)
      redirect_to jobseekers_job_applications_path, success: t("messages.jobseekers.job_applications.saved")
    elsif form.valid?
      if referrer_is_finish_wizard_path?
        job_application.update(update_params)
        redirect_to finish_wizard_path, success: t("messages.jobseekers.job_applications.saved")
      else
        job_application.assign_attributes(update_params)
        render_wizard job_application
      end
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

  def update_params
    form_params.merge(completed_steps: job_application.completed_steps.append(step).uniq)
  end

  def finish_wizard_path
    jobseekers_job_application_review_path(job_application)
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.draft.find(params[:job_application_id])
  end

  def process_steps
    @process_steps ||= ProcessSteps.new(steps: steps_config, adjust: 0, step: step)
  end

  def referrer_is_finish_wizard_path?
    URI(request.referrer || "").path == finish_wizard_path || URI(params[:origin] || "").path == finish_wizard_path
  end

  def vacancy
    @vacancy ||= job_application.vacancy
  end
end
