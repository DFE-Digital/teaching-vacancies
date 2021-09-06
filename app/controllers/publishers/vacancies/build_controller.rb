class Publishers::Vacancies::BuildController < Publishers::Vacancies::BaseController
  include Wicked::Wizard
  include OrganisationHelper

  steps :job_role, :job_role_details, :job_location, :schools, :job_details, :pay_package,
        :important_dates, :documents, :applying_for_the_job, :job_summary

  helper_method :back_path, :form

  before_action :strip_checkbox_params, only: %i[update]
  before_action :set_multiple_schools
  before_action :set_school_options

  helper_method :current_publisher_preference

  def show
    case step
    when :job_role_details
      skip_step if vacancy.main_job_role == "sendco"
    when :job_location
      skip_step if current_organisation.school?
    when :schools
      skip_step if current_organisation.school? || job_location == "central_office"
    when :documents
      return redirect_to(organisation_job_documents_path(vacancy.id))
    end

    render_wizard
  end

  def update
    if params[:commit] == t("buttons.save_and_return_later")
      save_listing_and_return_later
    elsif form.valid?
      update_vacancy
      if params[:commit] == t("buttons.update_job") ||
         (params[:commit] == t("buttons.continue") && session[:current_step].in?(%i[edit_incomplete review]))
        update_listing
      else
        render_wizard vacancy
      end
    else
      render_wizard
    end
  end

  private

  def back_path
    return finish_wizard_path if session[:current_step] == :review

    case step
    when :job_details
      if current_organisation.school?
        vacancy.main_job_role == "sendco" ? wizard_path(:job_role) : wizard_path(:job_role_details)
      else
        vacancy.central_office? ? wizard_path(:job_location) : wizard_path(:schools)
      end
    when :job_location
      vacancy.main_job_role == "sendco" ? wizard_path(:job_role) : wizard_path(:job_role_details)
    else
      previous_wizard_path
    end
  end

  def form
    @form ||= "Publishers::JobListing::#{step.to_s.camelize}Form".constantize.new(form_attributes, vacancy)
  end

  def form_attributes
    case action_name
    when "show"
      vacancy.slice(*send("#{step}_fields"))
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
    edit_organisation_job_path(vacancy.id)
  end

  def save_listing_and_return_later
    update_vacancy
    vacancy.save(validate: false)
    redirect_saved_draft_with_message
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
    if step == :job_location && job_location != "central_office"
      redirect_to wizard_path(:schools)
    elsif step == :job_role && vacancy.main_job_role != "sendco"
      redirect_to wizard_path(:job_role_details)
    else
      redirect_updated_job_with_message
    end
  end

  def update_vacancy
    vacancy.assign_attributes(form.params_to_save)
    vacancy.refresh_slug
    update_google_index(vacancy) if vacancy.listed?
  end
end
