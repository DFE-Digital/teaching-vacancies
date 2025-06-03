class JobApplicationReviewComponent::Section < ReviewComponent::Section
  include JobApplicationsHelper
  include VacanciesHelper

  def initialize(job_application, name:, id: nil, allow_edit: nil, forms: [], classes: [], html_attributes: {})
    super(
      job_application,
      forms: forms,
      name: name,
      id: id,
      classes: classes,
      html_attributes: html_attributes
    )

    @allow_edit = allow_edit
    @job_application = job_application
  end

  private

  def heading_text
    t("jobseekers.native_job_applications.build.#{@name}.heading")
  end

  def edit_link
    title = heading_text
    text = "Change"
    href = error_path
    govuk_link_to text, href, aria: { label: "#{text} #{title}" }, classes: "govuk-!-display-none-print" if href && allow_edit?
  end

  def constantize_form(form_class_name)
    "Jobseekers::JobApplication::#{form_class_name}".constantize
  end

  def error_path
    jobseekers_job_application_build_path(@job_application, @name) if @job_application.persisted?
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def allow_edit?
    return @allow_edit unless @allow_edit.nil?

    @job_application.allow_edit?
  end
end
