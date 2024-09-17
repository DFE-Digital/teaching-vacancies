class Jobseekers::JobApplications::BuildController < Jobseekers::JobApplications::BaseController
  include Wicked::Wizard
  include Jobseekers::QualificationFormConcerns

  steps :personal_details, :professional_status, :qualifications, :training_and_cpds, :employment_history, :personal_statement, :references,
        :equal_opportunities, :ask_for_support, :declarations

  helper_method :back_path, :employments, :form, :job_application, :qualification_form_param_key, :redirect_to_review?, :vacancy

  def show
    skip_step_if_missing

    render_wizard
  end

  def update
    if form.valid?
      job_application.update(update_params.except(:teacher_reference_number, :has_teacher_reference_number))
      update_or_create_jobseeker_profile! if step == :professional_status

      return redirect_to finish_wizard_path, success: t("messages.jobseekers.job_applications.saved") if redirect_to_review?

      render_wizard job_application
    else
      render_wizard
    end
  end

  private

  def back_path
    @back_path ||= if redirect_to_review?
                     finish_wizard_path
                   elsif step == :personal_details
                     new_jobseekers_job_job_application_path(vacancy.id)
                   else
                     jobseekers_job_application_build_path(job_application.id, step_process.previous_step)
                   end
  end

  def form
    @form ||= form_class.new(form_attributes)
  end

  def form_class
    "jobseekers/job_application/#{step}_form".camelize.constantize
  end

  def form_attributes
    attributes = case action_name
                 when "show"
                   job_application.attributes.slice(*form_class.fields.map(&:to_s))
                 when "update"
                   form_params
                 end

    if step == :professional_status
      attributes.merge!(jobseeker_profile_attributes)
      attributes.merge!(trn_params)
    end

    attributes
  end

  def form_params
    param_key = ActiveModel::Naming.param_key(form_class)

    (params[param_key] || params).permit(form_class.fields)
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
    current_jobseeker.job_applications.not_draft.any? || session[:back_to_review]&.include?(job_application.id)
  end

  def update_params
    if step_incomplete?
      update_fields.merge(
        completed_steps: job_application.completed_steps.delete_if { |completed_step| completed_step == step.to_s },
        in_progress_steps: job_application.in_progress_steps.append(step.to_s).uniq,
      )
    else
      update_fields.merge(
        completed_steps: job_application.completed_steps.append(step.to_s).uniq,
        in_progress_steps: job_application.in_progress_steps.delete_if { |in_progress_step| in_progress_step == step.to_s },
      )
    end
  end

  def update_fields
    form_params.except(*form_class.unstorable_fields)
  end

  def step_incomplete?
    return false unless step.in? %i[qualifications employment_history training_and_cpds]

    form_params["#{step}_section_completed"] == "false"
  end

  def vacancy
    @vacancy ||= job_application.vacancy
  end

  def skip_step_if_missing
    # Calling step_process will initialize a StepProcess, which will raise if the current step is missing.
    step_process
  rescue StepProcess::MissingStepError
    skip_step unless step == "wicked_finish"
  end

  def jobseeker_profile_attributes
    {
      jobseeker_profile: current_jobseeker.jobseeker_profile,
    }
  end

  def trn_params
    return {} unless step == :professional_status

    {
      teacher_reference_number: form_params[:teacher_reference_number] || current_jobseeker&.jobseeker_profile&.teacher_reference_number,
      has_teacher_reference_number: form_params[:has_teacher_reference_number] || current_jobseeker&.jobseeker_profile&.has_teacher_reference_number,
    }
  end

  def update_or_create_jobseeker_profile!
    if current_jobseeker.jobseeker_profile.nil?
      current_jobseeker.create_jobseeker_profile(
        teacher_reference_number: form_params[:teacher_reference_number],
        has_teacher_reference_number: form_params[:has_teacher_reference_number],
      )
    else
      current_jobseeker.jobseeker_profile.update(
        teacher_reference_number: form_params[:teacher_reference_number],
        has_teacher_reference_number: form_params[:has_teacher_reference_number],
      )
    end
  end
end
