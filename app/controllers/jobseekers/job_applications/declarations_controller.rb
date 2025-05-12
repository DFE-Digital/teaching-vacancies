class Jobseekers::JobApplications::DeclarationsController < Jobseekers::BaseController
  include Wicked::Wizard

  steps :personal_details, :barred_list, :conduct, :confirmation

  before_action :form

  helper_method :job_application

  def show
    render_wizard
  end

  def update
    if UpdateDeclarationsForm.call(form)
      redirect_to_next_step
    else
      render_wizard
    end
  end

  private

  def form_class
    "jobseekers/declarations/#{step}_form".camelize.constantize
  end

  def form
    # @form ||= form_class.new(job_application.declarations)
    @form ||= form_class.new
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end
end
