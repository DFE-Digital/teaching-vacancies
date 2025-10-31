class Publishers::Vacancies::BuildController < Publishers::Vacancies::WizardBaseController
  include Wicked::Wizard
  include OrganisationsHelper

  before_action :set_steps
  before_action :setup_wizard

  helper_method :form

  before_action :strip_checkbox_params, only: %i[update]
  before_action :set_school_options

  helper_method :current_publisher_preference

  def show
    @form = form_class.new(form_class.load_form(vacancy), vacancy, current_publisher)
    case current_step
    when :documents
      return redirect_to(new_organisation_job_document_path(vacancy.id,
                                                            back_to_review: params[:back_to_review],
                                                            back_to_show: params[:back_to_show]))
    end

    render_wizard
  end

  def update
    @form = form_class.new(form_params, vacancy, current_publisher)

    if @form.valid?
      if user_chose_not_to_confirm_contact_email?
        redirect_to organisation_job_build_path(vacancy.id, step_process.previous_step)
      else
        update_vacancy
        redirect_to_next_step
      end
    else
      render_wizard
    end
  end

  private

  attr_reader :form

  def user_chose_not_to_confirm_contact_email?
    step.name == "confirm_contact_details" && @form.confirm_contact_email == "false"
  end

  def form_class
    "publishers/job_listing/#{step}_form".camelize.constantize
  end

  def form_params
    send(:"#{step}_params", params)
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

    strip_empty_checkboxes(STRIP_CHECKBOXES[step], :"publishers_job_listing_#{step}_form")
  end

  def update_vacancy
    updated_completed_steps = completed_steps(steps_to_reset: form.steps_to_reset)
    vacancy.assign_attributes(form.params_to_save.merge(completed_steps: updated_completed_steps))
    vacancy.refresh_slug
    update_google_index(vacancy) if vacancy.live?

    vacancy.save
  end

  def set_steps
    self.steps = step_process.steps - [:review]
  end
end
