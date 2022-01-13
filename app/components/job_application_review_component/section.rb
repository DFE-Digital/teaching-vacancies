class JobApplicationReviewComponent::Section < ReviewComponent::Section
  include JobApplicationsHelper
  include VacanciesHelper

  def initialize(job_application, forms: [], classes: [], html_attributes: {}, **kwargs)
    super(
      job_application,
      forms: forms,
      classes: classes,
      html_attributes: html_attributes,
      **kwargs,
    )

    @job_application = job_application
  end

  private

  def heading_text
    t("jobseekers.job_applications.build.#{@name}.heading")
  end

  def build_list
    list = nil
    govuk_summary_list { |l| list = l }
    list
  end

  def constantize_form(form_class_name)
    "Jobseekers::JobApplication::#{form_class_name}".constantize
  end

  def error_path(**params)
    jobseekers_job_application_build_path(@job_application, @name, **params)
  end

  def error_link_text
    job_application_review_edit_section_text(@job_application, @name)
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  def allow_edit?
    !@job_application.deadline_passed?
  end
end
