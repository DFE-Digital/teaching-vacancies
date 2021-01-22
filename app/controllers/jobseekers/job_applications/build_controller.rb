class Jobseekers::JobApplications::BuildController < Jobseekers::ApplicationController
  include Wicked::Wizard

  steps :personal_details

  before_action :set_up_job_application
  before_action :set_up_show_form, only: %i[show]
  before_action :set_up_update_form, only: %i[update]

  def show
    render_wizard
  end

  def update
    application_data = @job_application.application_data.presence || {}

    if @form.valid?
      @job_application.assign_attributes(application_data: application_data.merge(personal_details_params))
      render_wizard @job_application
    else
      render_wizard
    end
  end

  private

  def personal_details_params
    ParameterSanitiser.call(params).require(:jobseekers_job_application_personal_details_form).permit(:first_name)
  end

  def finish_wizard_path
    jobseekers_job_application_review_path(@job_application)
  end

  def set_up_show_form
    return if step == "wicked_finish"

    @form = Jobseekers::JobApplication::PersonalDetailsForm.new
  end

  def set_up_update_form
    @form = Jobseekers::JobApplication::PersonalDetailsForm.new(personal_details_params)
  end

  def set_up_job_application
    @job_application = current_jobseeker.job_applications.find(params[:job_application_id])
  end
end
