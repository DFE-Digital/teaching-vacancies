class Publishers::Vacancies::BuildController < Publishers::Vacancies::BaseController
  include Wicked::Wizard
  include OrganisationHelper
  include VacanciesOptionsHelper

  steps :job_location, :schools, :job_details, :pay_package, :important_dates, :documents, :applying_for_the_job,
        :job_summary

  helper_method :back_path, :form

  before_action :strip_checkbox_params, only: %i[update]
  before_action :set_multiple_schools
  before_action :set_school_options
  before_action :show_errors_after_redirect, only: %i[show]

  helper_method :current_publisher_preference

  def show
    case step
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
      if params[:commit] == t("buttons.update_job") || updating_vacancy? # Button text differs on part 1 of multi-part steps
        vacancy.save
        if next_part_of_step_required?
          redirect_to wizard_path(next_step)
        else
          redirect_updated_job_with_message
        end
      else
        render_wizard vacancy
      end
    else
      render_wizard
    end
  end

  private

  def back_path
    @back_path ||= if session[:current_step] == :review
                     finish_wizard_path
                   elsif step == :job_details && !current_organisation.school?
                     vacancy.central_office? ? wizard_path(:job_location) : wizard_path(:schools)
                   else
                     previous_wizard_path
                   end
  end

  def current_publisher_preference
    current_publisher.publisher_preferences.find_by(organisation: current_organisation)
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

  def next_part_of_step_required?
    (step == :job_location && job_location != "central_office")
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

  def show_errors_after_redirect
    # Otherwise the user will be redirected to a step they think they have already completed, with no explanation as to
    # what they need to do to proceed with creating their listing.
    form.valid? if vacancy.completed_steps.include?(step.to_s) && params[:errors] == "true"
  end

  def strip_checkbox_params
    return unless STRIP_CHECKBOXES.key?(step)

    strip_empty_checkboxes(STRIP_CHECKBOXES[step], "publishers_job_listing_#{step}_form".to_sym)
  end

  def update_vacancy
    vacancy.assign_attributes(form.params_to_save)
    vacancy.refresh_slug
    update_google_index(vacancy) if vacancy.listed?
  end
end
