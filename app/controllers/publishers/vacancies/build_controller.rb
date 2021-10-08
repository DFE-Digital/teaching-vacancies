class Publishers::Vacancies::BuildController < Publishers::Vacancies::BaseController
  include Wicked::Wizard
  include OrganisationsHelper

  steps :job_role, :job_role_details, :job_location, :schools, :education_phases, :job_details, :working_patterns,
        :pay_package, :important_dates, :documents, :applying_for_the_job, :job_summary

  helper_method :back_path, :form

  before_action :strip_checkbox_params, only: %i[update]
  before_action :set_multiple_schools
  before_action :set_school_options

  helper_method :current_publisher_preference

  def show
    skip_step_if_missing

    return redirect_to(organisation_job_documents_path(vacancy.id)) if step == :documents

    return redirect_to(reminder_new_features_path) if show_application_reminder

    render_wizard
  end

  def update
    if form.valid?
      update_vacancy
      if session[:current_step] == :review
        update_listing
      else
        render_wizard vacancy
      end
    else
      render_wizard
    end
  end

  private

  def show_application_reminder
    most_recent_vacancy = Vacancy.where(publisher_id: current_publisher.id).order("created_at").last

    !session[:visited_application_feature_reminder_page] && current_publisher.viewed_new_features_page_at && most_recent_vacancy.created_at > current_publisher.viewed_new_features_page_at && !most_recent_vacancy.enable_job_applications
  end

  def form
    @form ||= form_class.new(form_attributes, vacancy)
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

  def job_location
    @job_location ||= session[:job_location].presence || vacancy.job_location
  end

  def finish_wizard_path
    organisation_job_review_path(vacancy.id)
  end

  def set_multiple_schools
    return unless step == :schools && current_organisation.school_group?

    @multiple_schools = job_location == "at_multiple_schools"
  end

  def set_school_options
    return unless step == :schools && current_organisation.school_group?

    schools = current_organisation.local_authority? ? current_publisher_preference.schools : current_organisation.schools
    @school_options = schools.not_closed.order(:name).map do |school|
      OpenStruct.new({ id: school.id, name: school.name, address: full_address(school) })
    end
  end

  def current_publisher_preference
    current_publisher.publisher_preferences.find_by(organisation: current_organisation)
  end

  def strip_checkbox_params
    return unless STRIP_CHECKBOXES.key?(step)

    strip_empty_checkboxes(STRIP_CHECKBOXES[step], "publishers_job_listing_#{step}_form".to_sym)
  end

  def update_listing
    vacancy.save

    if step_process.last_of_group?
      redirect_updated_job_with_message
    else
      redirect_to wizard_path(step_process.next_step)
    end
  end

  def update_vacancy
    vacancy.assign_attributes(form.params_to_save)
    vacancy.set_postcode_from_mean_geolocation(persist: false)
    vacancy.refresh_slug
    update_google_index(vacancy) if vacancy.listed?
  end

  def skip_step_if_missing
    # Calling step_process will initialize a StepProcess, which will raise if the current step is missing.
    step_process
  rescue StepProcess::MissingStepError
    skip_step unless step == "wicked_finish"
  end
end
