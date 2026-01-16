class Jobseekers::JobApplications::BuildController < Jobseekers::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns

  before_action :strip_empty_working_patterns_checkboxes, only: %i[update]

  helper_method :back_path, :employments, :job_application, :qualification_form_param_key, :redirect_to_review?, :vacancy

  def show
    @form = form_class.new(form_class.load_form(job_application))
    render step
  end

  def update
    @form = form_class.new(form_class.load_form(job_application).merge(form_params))
    if @form.valid?
      job_application.update!(update_params)

      if redirect_to_review?
        redirect_to jobseekers_job_application_review_path(job_application), success: t("messages.jobseekers.job_applications.saved")
      elsif steps_complete?
        redirect_to jobseekers_job_application_apply_path job_application
      else
        redirect_to jobseekers_job_application_build_path(job_application, step_process.next_step(step))
      end
    else
      render step
    end
  end

  private

  def steps_complete?
    step_process.last_of_group?(step)
  end

  def back_path
    @back_path ||= if redirect_to_review?
                     jobseekers_job_application_review_path(job_application)
                   else
                     jobseekers_job_application_apply_path job_application
                   end
  end

  def step
    params[:id].to_sym
  end

  def form_class
    step_process.form_class_for(step)
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
    session[:back_to_review]&.include?(job_application.id)
  end

  def update_params
    if step_incomplete?
      update_fields.merge(
        completed_steps: remove_current_step(job_application.completed_steps),
        in_progress_steps: job_application.in_progress_steps.append(step.to_s).uniq,
      )
    else
      update_fields.merge(
        completed_steps: job_application.completed_steps.append(step.to_s).uniq,
        in_progress_steps: remove_current_step(job_application.in_progress_steps),
      )
    end.merge(imported_steps: remove_current_step(job_application.imported_steps))
  end

  def remove_current_step(steps)
    steps.delete_if { |the_step| the_step == step.to_s }
  end

  def update_fields
    # This version doesn't work with date fields as they are submitted in 3 parts (hence form_params doesn't contain the right key)
    # form_class.storable_fields.select { |f| form_params.key?(f) }.index_with { |field| form.public_send(field) }
    form_params.except(*form_class.unstorable_fields)
  end

  def step_incomplete?
    form_params["#{step}_section_completed"] == "false"
  end

  def vacancy
    @vacancy ||= job_application.vacancy
  end

  def strip_empty_working_patterns_checkboxes
    strip_empty_checkboxes(%i[working_patterns], :jobseekers_job_application_personal_details_form)
  end
end
