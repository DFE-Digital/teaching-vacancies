class Jobseekers::JobApplications::SelfDisclosureController < Jobseekers::BaseController
  include Wicked::Wizard

  before_action :redirect_when_self_disclosure_not_pending, except: :completed
  before_action :set_form, except: :completed

  FORMS = {
    personal_details: Jobseekers::JobApplications::SelfDisclosure::PersonalDetailsForm,
    barred_list: Jobseekers::JobApplications::SelfDisclosure::BarredListForm,
    conduct: Jobseekers::JobApplications::SelfDisclosure::ConductForm,
    confirmation: Jobseekers::JobApplications::SelfDisclosure::ConfirmationForm,
  }.freeze

  steps(*FORMS.keys)

  def show
    render_wizard
  end

  def update
    if @form.valid?
      @form.save_model!
      if next_step == Wicked::FINISH_STEP
        self_disclosure.self_disclosure_request.received!
        redirect_to finish_wizard_path
      else
        redirect_to next_wizard_path
      end
    else
      render_wizard
    end
  end

  def completed; end

  private

  def set_form
    @form = form_class.new(form_params).tap { it.model = self_disclosure }
  end

  def form_class
    FORMS.fetch(step)
  end

  def form_param_key
    ActiveModel::Naming.param_key(form_class)
  end

  def form_params
    params.fetch(form_param_key, {}).permit(*form_class.fields)
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end

  def self_disclosure
    job_application.self_disclosure
  end

  def redirect_when_self_disclosure_not_pending
    return if self_disclosure && self_disclosure.self_disclosure_request.sent?

    redirect_to(jobseekers_job_application_path(job_application))
  end

  def finish_wizard_path
    completed_jobseekers_job_application_self_disclosure_index_path(job_application)
  end
end
