class Jobseekers::JobApplications::BuildController < Jobseekers::ApplicationController
  include Wicked::Wizard
  include Jobseekers::Wizardable

  steps :personal_details, :professional_status, :personal_statement, :ask_for_support, :declarations

  before_action :set_up_job_application, :set_up_current_step_number
  before_action :set_up_show_form, only: %i[show]
  before_action :set_up_update_form, only: %i[update]

  def show
    render_wizard
  end

  def update
    application_data = @job_application.application_data.presence || {}

    if @form.valid?
      @job_application.assign_attributes(application_data: application_data.merge(form_params))
      if params[:commit] == t("buttons.save_as_draft")
        save_job_application_as_draft
      else
        render_wizard @job_application
      end
    else
      render_wizard
    end
  end

  private

  def form_params
    send(FORM_PARAMS[step], params)
  end

  def finish_wizard_path
    jobseekers_job_application_review_path(@job_application)
  end

  def save_job_application_as_draft
    @job_application.save
    redirect_to jobseekers_saved_jobs_path, success: t(".saved_job_application")
  end

  def set_up_current_step_number
    @current_step_number = STEPS[step]
  end

  def set_up_show_form
    return if step == "wicked_finish"

    @form = FORMS[step].new
  end

  def set_up_update_form
    @form = FORMS[step].new(form_params)
  end

  def set_up_job_application
    @job_application = current_jobseeker.job_applications.find(params[:job_application_id])
  end
end
