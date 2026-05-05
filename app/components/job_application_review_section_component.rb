class JobApplicationReviewSectionComponent < ApplicationComponent
  include JobApplicationsHelper
  include VacanciesHelper
  include StatusTagHelper

  renders_many :field_div_sets, ->(form: nil) { render_divs_for_fields(form) }

  def initialize(job_application, name, forms: [])
    super()

    forms << "#{name.to_s.camelize}Form" if forms.empty?

    @forms = forms.map { |f| constantize_form(f) }
    @name = name
    @job_application = job_application
  end

  private

  def heading_text
    t("jobseekers.job_applications.build.#{@name}.heading")
  end

  def edit_link
    title = heading_text
    text = "Change"
    href = error_path
    govuk_link_to text, href, aria: { label: "#{text} #{title}" }, classes: "govuk-!-display-none-print" if href && allow_edit?
  end

  def constantize_form(form_class_name)
    return "Jobseekers::UploadedJobApplication::#{form_class_name}".constantize if form_class_name == "UploadApplicationFormForm"

    "Jobseekers::JobApplication::#{form_class_name}".constantize
  end

  def error_path
    if @job_application.vacancy.uploaded_form?
      return edit_jobseekers_uploaded_job_application_personal_details_path(@job_application) if @name == :personal_details

      # :nocov:
      edit_jobseekers_uploaded_job_application_upload_application_form_path(@job_application) if @name == :upload_application_form
      # :nocov:
    elsif @job_application.persisted?
      jobseekers_job_application_build_path(@job_application, @name)
    end
  end

  def allow_edit?
    @job_application.allow_edit?
  end

  def render_divs_for_fields(form_model)
    fields = form_model.fields.map { |field| field.is_a?(Hash) ? field.keys.first : field }
    safe_join(fields.map { |field| tag.div(id: field) })
  end

  def before_render
    with_field_div_sets(@forms.map { |f| { form: f } })
  end

  def default_classes
    %w[review-component__section]
  end
end
