class HiringStaff::Vacancies::BuildController < HiringStaff::Vacancies::ApplicationController
  include Wicked::Wizard
  include CreateAJobConcerns
  include OrganisationHelper

  steps :job_location, :schools, :job_details, :pay_package, :important_dates,
        :supporting_documents, :documents, :applying_for_the_job, :job_summary

  before_action :set_vacancy
  before_action :convert_date_params, only: %i[update]
  before_action :strip_checkbox_params, only: %i[update]
  before_action :set_school_options
  before_action :set_up_show_form, only: %i[show]
  before_action :set_up_update_form, only: %i[update]

  def show
    case step
    when :job_location
      skip_step if current_organisation.is_a?(School)
    when :schools
      skip_step if current_organisation.is_a?(School) || @vacancy.central_office?
    when :job_details
      @job_details_back_path = @vacancy.central_office? ? wizard_path(:job_location) : wizard_path(:schools)
    when :supporting_documents
      if params[:change] == "true"
        @vacancy.update(supporting_documents: "yes")
        skip_step
      end
    when :documents
      if @vacancy.supporting_documents == "no"
        skip_step
      else
        return redirect_to organisation_job_documents_path(@vacancy.id)
      end
    when :applying_for_the_job
      @applying_for_the_job_back_path = @vacancy.supporting_documents == "no" ? wizard_path(:supporting_documents) : wizard_path(:documents)
    end

    render_wizard
  end

  def update
    if params[:commit] == I18n.t("buttons.save_and_return_later")
      update_vacancy
      @vacancy.save(validate: false)
      redirect_saved_draft_with_message
    elsif @form.complete_and_valid?
      update_vacancy
      if params[:commit] == I18n.t("buttons.update_job")
        @vacancy.save
        if step == :job_location && !@vacancy.central_office?
          redirect_to wizard_path(:schools)
        else
          redirect_updated_job_with_message
        end
      elsif params[:commit] == I18n.t("buttons.continue") && session[:current_step] == :review
        @vacancy.save
        if step == :supporting_documents && @vacancy.supporting_documents == "yes"
          redirect_to wizard_path(:documents)
        else
          redirect_updated_job_with_message
        end
      else
        render_wizard @vacancy
      end
    else
      replace_errors_in_form(@date_errors, @form) if step == :important_dates
      render_wizard
    end
  end

private

  def convert_date_params
    return unless step == :important_dates

    publish_in_past = @vacancy.published? && @vacancy.reload.publish_on.past?
    delete_publish_on_params if @vacancy.published? && @vacancy.reload.publish_on.past?
    dates_to_convert = publish_in_past ? %i[starts_on expires_on] : %i[starts_on publish_on expires_on]
    @date_errors = convert_multiparameter_attributes_to_dates(:important_dates_form, dates_to_convert)
  end

  def delete_publish_on_params
    params.require(:important_dates_form).delete("publish_on(3i)")
    params.require(:important_dates_form).delete("publish_on(2i)")
    params.require(:important_dates_form).delete("publish_on(1i)")
  end

  def finish_wizard_path
    edit_organisation_job_path(@vacancy.id)
  end

  def set_school_options
    return unless step == :schools && current_organisation.is_a?(SchoolGroup)

    @school_options = current_organisation.schools.order(:name).map do |school|
      OpenStruct.new({ id: school.id, name: school.name, address: full_address(school) })
    end
  end

  def set_up_show_form
    return if step == "wicked_finish"

    @form = VACANCY_FORMS[step].new(@vacancy.attributes.symbolize_keys.merge(organisation_ids: @vacancy.organisation_ids))
  end

  def set_up_update_form
    @form = VACANCY_FORMS[step].new(send(VACANCY_FORM_PARAMS[step], params))
    @form.id = @vacancy.id
    @form.status = @vacancy.status
  end

  def strip_checkbox_params
    if VACANCY_STRIP_CHECKBOXES.key?(step)
      strip_empty_checkboxes(VACANCY_STRIP_CHECKBOXES[step], "#{step}_form".to_sym)
    end
  end

  def update_vacancy
    @vacancy.assign_attributes(@form.params_to_save)
    @vacancy.refresh_slug
    update_google_index(@vacancy) if @vacancy.listed?
  end
end
