class Jobseekers::JobApplications::BuildController < Jobseekers::JobApplications::BaseController
  include Jobseekers::QualificationFormConcerns
  before_action :strip_empty_working_patterns_checkboxes, only: %i[update]

  helper_method :back_path, :employments, :form, :job_application, :qualification_form_param_key, :redirect_to_review?, :vacancy

  def show
    render step
  end

  def update
    if form.valid?
      job_application.update!(update_params.except(:teacher_reference_number, :has_teacher_reference_number))
      update_or_create_jobseeker_profile! if step == :professional_status

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
    step_process.last_of_group?(step) || (step.in?(%i[catholic_following_religion non_catholic_following_religion]) && !job_application.following_religion)
  end

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
    "jobseekers/job_application/#{step}_form".camelize.constantize
  end

  def form_attributes
    attributes = case action_name
                 when "show"
                   form_class.load_form(job_application)
                 when "update"
                   form_class.load_form(job_application).merge(form_params)
                 end

    case step
    when :professional_status
      attributes.merge(trn_params)
    when :employment_history
      attributes.merge(unexplained_employment_gaps: job_application.unexplained_employment_gaps)
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

  def trn_params
    {
      teacher_reference_number: form_params[:teacher_reference_number] || current_jobseeker&.jobseeker_profile&.teacher_reference_number,
      has_teacher_reference_number: form_params[:has_teacher_reference_number] || current_jobseeker&.jobseeker_profile&.has_teacher_reference_number,
    }
  end

  # This set of fields needs to be a 'consistent' set rather than just a couple of fields.
  # A recent change in a before_save callback in the JobseekerProfile class meant that TRN related fields were not persisted unless qualified_teacher_status == "yes"
  # so we had to add qualified_teacher_status here.
  #
  # Without this, the JobseekerProfile class thinks that the QTS status is 'no' (!= yes) and understandably clears some fields to prevent an inconsistently saved state.
  # However the lack of data validation means/meant that this error wasn't caught.
  # Possibly a better strategy would be to have data validation, but to use validate: false when it is known that the data is incomplete
  # (e.g. when part completing a vacancy or job application)
  # This type of strategy would have caught this as the code would have noticed that qualified_teacher_status was not one of yes/no/on_track.
  # In order for this to be implemented effectively, the JobseekerProfile would need to split out the its professional status fields.
  #
  def update_or_create_jobseeker_profile!
    profile_params = form_params.slice(:teacher_reference_number, :has_teacher_reference_number, :qualified_teacher_status)
    if current_jobseeker.jobseeker_profile.nil?
      current_jobseeker.create_jobseeker_profile!(profile_params)
    else
      current_jobseeker.jobseeker_profile.update!(profile_params)
    end
  end

  def strip_empty_working_patterns_checkboxes
    strip_empty_checkboxes(%i[working_patterns], :jobseekers_job_application_personal_details_form)
  end
end
