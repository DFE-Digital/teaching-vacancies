class Jobseekers::JobApplications::SelfDisclosureController < Jobseekers::BaseController
  include Wicked::Wizard

  before_action :redirect_when_not_available
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
    form.load_model_data
    render_wizard
  end

  def update
    result, @form = Jobseekers::JobApplications::UpdateSelfDisclosureForm.call(form, step, FORMS.keys)
    case result
    when :wizard
      redirect_to jobseekers_job_application_self_disclosure_path(job_application, next_step)
    when :done
      redirect_to completed_jobseekers_job_application_self_disclosure_index_path(job_application)
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
    @form_class ||= FORMS.fetch(step)
  end

  def form_params_key
    @form_params_key ||= form_class.name.underscore.tr("/", "_")
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
    SelfDisclosure.find_or_create_by(job_application: job_application)
  end

  def redirect_when_not_available
    return if job_application.self_disclosure_available?

    redirect_to jobseekers_job_applications_path
  end
end
