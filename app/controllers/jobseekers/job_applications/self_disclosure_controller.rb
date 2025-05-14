class Jobseekers::JobApplications::SelfDisclosureController < Jobseekers::BaseController
  include Wicked::Wizard

  steps :personal_details, :barred_list, :conduct, :confirmation, :completed

  before_action :form

  helper_method :job_application

  def show
    render_wizard
  end

  def update
    successful, @form = Jobseekers::JobApplications::UpdateSelfDisclosureForm.call(form, job_application)
    if successful
      redirect_to jobseekers_job_application_self_disclosure_path(job_application, next_step)
    else
      render_wizard
    end
  end

  private

  def form_path
    @form_path ||= ["jobseekers", "job_applications", "self_disclosure", "#{step}_form"]
  end

  def form_class
    form_path.join("/").camelize.constantize
  end

  def form_attributes
    form_class.new.attributes.keys
  end

  def form_params_key
    @form_params_key ||= form_path.join("_").to_sym
  end

  def form_params
    return {} if params[form_params_key].blank?

    params
      .require(form_params_key)
      .tap { it.merge!(date_of_birth: parse_dob) if step == :personal_details }
      .permit(*form_attributes)
  end

  def form
    @form ||= form_class.new(form_params)
  end

  def job_application
    @job_application ||= current_jobseeker.job_applications.find(params[:job_application_id])
  end

  def parse_dob
    year = params[form_params_key].delete("date_of_birth(1i)")
    month = params[form_params_key].delete("date_of_birth(2i)")
    day = params[form_params_key].delete("date_of_birth(3i)")

    return nil unless year.present? && month.present? && day.present?

    [year, month, day].join("-")
  end
end
