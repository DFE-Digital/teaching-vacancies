class Jobseekers::JobApplications::SelfDisclosureController < Jobseekers::BaseController
  include Wicked::Wizard

  before_action :redirect_when_self_disclosure_not_pending, except: :completed
  before_action :form, except: :completed

  helper_method :job_application

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
    if form.update!
      if next_step == "wicked_finish"
        self_disclosure.self_disclosure_request.received!
        # when next_step is nil redirect_to_next goes to the finish_wizard_path
        redirect_to_next(nil)
      else
        redirect_to_next(next_step)
      end
    else
      render_wizard
    end
  end

  def completed; end

  private

  def form
    @form ||= form_class.new(form_params).tap { it.model = self_disclosure }
  end

  def form_class
    FORMS.fetch(step)
  end

  def form_params_key
    form_class.name.underscore.tr("/", "_")
  end

  def form_params
    params
      .fetch(form_params_key, {})
      .tap { flatten_enumerable_value(it) }
      .tap { parse_dob(it) }
      .permit(*form_class.new.attributes)
  end

  def flatten_enumerable_value(hsh)
    hsh.each do |k, v|
      hsh[k] = v.first if v.is_a?(Enumerable)
    end
  end

  def parse_dob(hsh)
    return if step != :personal_details

    year = hsh.delete("date_of_birth(1i)")
    month = hsh.delete("date_of_birth(2i)")
    day = hsh.delete("date_of_birth(3i)")
    return nil unless year.present? && month.present? && day.present?

    hsh["date_of_birth"] = [year, month, day].join("-")
    hsh
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
