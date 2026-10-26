class Publishers::Vacancies::BuildController < Publishers::Vacancies::WizardBaseController
  include Wicked::Wizard
  include OrganisationsHelper

  before_action :set_vacancy, only: %i[show update]

  before_action :set_steps
  before_action :setup_wizard

  helper_method :form

  before_action :strip_checkbox_params, only: %i[update]
  before_action :set_school_options

  helper_method :current_publisher_preference

  NON_VALIDATING_FORMS = %i[job_location
                            job_title
                            confirm_job_address
                            job_role
                            education_phases
                            key_stages
                            contract_information
                            start_date
                            pay_package].freeze

  def show
    @form = form_class.load_from_model(@vacancy, current_publisher: current_publisher)
    case step
    when :documents
      return redirect_to(new_organisation_job_document_path(@vacancy.id,
                                                            back_to_review: params[:back_to_review],
                                                            back_to_show: params[:back_to_show]))
    end

    skip_step unless step_process.steps.fetch(step)
    render_wizard
  end

  def update
    @form = form_class.load_from_params(form_params, @vacancy, current_publisher: current_publisher)
    @vacancy.assign_attributes(@form.params_to_save)

    if step.in? NON_VALIDATING_FORMS
      validate_model_and_redirect
    elsif @form.valid?
      update_vacancy
      @vacancy.save!(validate: false)

      redirect_to_next_wizard_step []
    else
      render_wizard
    end
  end

  private

  def validate_model_and_redirect
    @vacancy.validate
    error_keys = @vacancy.errors.attribute_names
    # Only show errors relevant to this form
    (error_keys - form_class.field_list).each do |error_key|
      @vacancy.errors.delete(error_key)
    end
    if @vacancy.errors.any?
      render_wizard
    else
      update_vacancy
      @vacancy.geocode_job_address if step == :confirm_job_address
      @vacancy.save!(validate: false)

      redirect_to_next_wizard_step error_keys
    end
  end

  def redirect_to_next_wizard_step(error_keys) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    next_wizard_step = if next_incomplete_step_confirm_job_address?
                         :confirm_job_address
                       elsif next_incomplete_step_subjects?
                         :subjects
                       elsif next_step.in? NON_VALIDATING_FORMS
                         steps.detect { |step| form_class_for_step(step).field_list.intersect?(error_keys) } || next_step
                       else
                         next_invalid_step
                       end

    if save_and_finish_later?
      redirect_to organisation_job_path(@vacancy.id), success: t("publishers.vacancies.show.success")
    elsif @vacancy.valid?
      if @vacancy.published?
        redirect_to organisation_job_path(@vacancy.id), success: t("publishers.vacancies.show.success")
      elsif next_step.present? && next_wizard_step.present?
        redirect_to organisation_job_build_path(@vacancy.id, next_wizard_step)
      else
        redirect_to organisation_job_review_path(@vacancy.id)
      end
    else
      redirect_to organisation_job_build_path(@vacancy.id, next_wizard_step)
    end
  end

  def update_vacancy
    updated_completed_steps = completed_steps(steps_to_reset: @form.steps_to_reset)
    @vacancy.assign_attributes(completed_steps: updated_completed_steps)
    @vacancy.refresh_slug
    update_google_index(@vacancy) if @vacancy.live?
  end

  def next_incomplete_step_confirm_job_address?
    return false unless steps.include?(:confirm_job_address)
    return false if @vacancy.completed_steps.include?("confirm_job_address")

    @vacancy.completed_steps.last == "job_title"
  end

  def next_incomplete_step_subjects?
    return false unless @vacancy.allow_subjects?
    return false if @vacancy.completed_steps.include?("subjects")

    @vacancy.completed_steps.last == if @vacancy.allow_key_stages?
                                       "key_stages"
                                     else
                                       "job_role"
                                     end
  end

  attr_reader :form

  def form_params
    if step == :important_dates && @vacancy.disable_editing_publish_on?
      expiry_date_time_params(params)
    elsif step == :about_the_role
      params.fetch(form_key, {}).permit(form_class.fields)
    else
      super
    end
  end

  def form_class
    form_class_for_step(step)
  end

  def form_class_for_step(step_name)
    if step_name == :important_dates && @vacancy.disable_editing_publish_on?
      Publishers::JobListing::ExpiryDateTimeForm
    else
      "publishers/job_listing/#{step_name}_form".camelize.constantize
    end
  end

  def form_key
    ActiveModel::Naming.param_key(form_class)
  end

  def set_school_options # rubocop:disable Metrics/AbcSize
    return unless step == :job_location && current_organisation.school_group?

    schools = current_organisation.local_authority? ? current_publisher_preference.schools : current_organisation.schools
    @school_options = schools.kept.order(:name).map do |school|
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

  def set_steps
    self.steps = step_process.all_steps.keys - [:review]
  end
end
