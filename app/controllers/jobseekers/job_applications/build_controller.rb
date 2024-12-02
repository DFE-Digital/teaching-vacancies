class Jobseekers::JobApplications::BuildController < Jobseekers::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns

  helper_method :back_path, :employments, :form, :job_application, :qualification_form_param_key, :redirect_to_review?, :vacancy

  def show
    render step
  end

  def update
    if form.valid?
      job_application.update(update_params.except(:teacher_reference_number, :has_teacher_reference_number))
      update_or_create_jobseeker_profile! if step == :professional_status

      if redirect_to_review? && (step_process.last_of_group? || (step.in?(%i[catholic_following_religion non_catholic_following_religion]) && !job_application.following_religion))
        redirect_to jobseekers_job_application_review_path(job_application), success: t("messages.jobseekers.job_applications.saved")
      else
        redirect_to jobseekers_job_application_apply_path job_application
      end
    else
      render step
    end
  end

  private

  def back_path
    @back_path ||= if redirect_to_review?
                     jobseekers_job_application_review_path(job_application)
                   else
                     jobseekers_job_application_apply_path job_application
                   end
  end

  def form
    @form ||= form_class.new(form_attributes)
  end

  def step
    params[:id].to_sym
  end

  def form_class
    if step.in? %i[catholic_following_religion non_catholic_following_religion]
      Jobseekers::JobApplication::FollowingReligionForm
    else
      "jobseekers/job_application/#{step}_form".camelize.constantize
    end
  end

  def form_attributes
    attributes = case action_name
                 when "show"
                   form_class.load_form(job_application)
                 when "update"
                   form_params
                 end

    attributes[:unexplained_employment_gaps] = job_application.unexplained_employment_gaps if step == :employment_history

    if step == :professional_status
      attributes.merge(jobseeker_profile_attributes)
                .merge(trn_params)
    elsif step == :references
      attributes.merge(references: job_application.references)
    else
      attributes
    end
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
    # This version doesn't work with date fields
    # form_class.storable_fields.select { |f| form_params.key?(f) }.index_with { |field| form.public_send(field) }
    form_params.except(*form_class.unstorable_fields)
  end

  def step_incomplete?
    form_params["#{step}_section_completed"] == "false"
  end

  def vacancy
    @vacancy ||= job_application.vacancy
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

  def set_steps
    self.steps = step_process.all_possible_steps - [:review]
  end
end
