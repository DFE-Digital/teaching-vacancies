class Publishers::Vacancies::BuildController < Publishers::Vacancies::BaseController
  include Wicked::Wizard
  include OrganisationsHelper

  steps :job_location, :job_role, :education_phases, :job_title, :key_stages, :subjects, :contract_type, :working_patterns,
        :pay_package, :important_dates, :start_date, :applying_for_the_job, :how_to_receive_applications, :application_link,
        :application_form, :school_visits, :contact_details, :about_the_role, :include_additional_documents, :documents

  helper_method :form

  before_action :strip_checkbox_params, only: %i[update]
  before_action :set_school_options

  helper_method :current_publisher_preference

  def show
    skip_step_if_missing

    return redirect_to(organisation_job_documents_path(vacancy.id, back_to_review: params[:back_to_review])) if current_step == :documents

    render_wizard
  end

  def update
    if form.valid?
      update_vacancy
      redirect_to_next_step
    else
      render_wizard
    end
  end

  private

  def form
    @form ||= form_class.new(form_attributes, vacancy, current_publisher)
  end

  def form_class
    "publishers/job_listing/#{step}_form".camelize.constantize
  end

  def form_attributes
    case action_name
    when "show"
      vacancy.slice(*form_class.fields)
    when "update"
      form_params
    end
  end

  def form_params
    send("#{step}_params", params)
  end

  def set_school_options
    return unless step == :job_location && current_organisation.school_group?

    schools = current_organisation.local_authority? ? current_publisher_preference.schools : current_organisation.schools
    @school_options = schools.not_closed.order(:name).map do |school|
      Option.new(id: school.id, name: school.name, address: full_address(school))
    end

    return if current_organisation.local_authority?

    @school_options.unshift(
      Option.new(id: current_organisation.id, name: t("organisations.job_location_heading.central_office"), address: full_address(current_organisation)),
    )
  end

  def current_publisher_preference
    current_publisher.publisher_preferences.find_by(organisation: current_organisation)
  end

  def strip_checkbox_params
    return unless STRIP_CHECKBOXES.key?(step)

    strip_empty_checkboxes(STRIP_CHECKBOXES[step], "publishers_job_listing_#{step}_form".to_sym)
  end

  def update_vacancy
    vacancy.assign_attributes(form.params_to_save)
    vacancy.refresh_slug
    update_google_index(vacancy) if vacancy.listed?

    vacancy.save
  end

  def skip_step_if_missing
    # Calling step_process will initialize a StepProcess, which will raise if the current step is missing.
    step_process
  rescue StepProcess::MissingStepError
    @step = "wicked_finish" if step == :documents
    skip_step unless step == "wicked_finish"
  end
end
