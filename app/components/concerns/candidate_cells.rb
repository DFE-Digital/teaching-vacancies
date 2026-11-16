# The contents of each column in a table of job applications, shared by CandidatesTableComponent
# and SelectableCandidatesTableComponent. Expects @vacancy to be set.
#
# Candidates must be JobApplicationDecorators, as the controller provides: the decorator hides
# personal details on anonymised vacancies.
module CandidateCells
  include JobApplicationsHelper

  # Date columns: how each date is shown, and the tag action that lets a publisher add it when it
  # is missing. Formats are in config/initializers/date_time_formats.rb. Only the interview has a
  # time, so only it shows one.
  DATE_FIELDS = {
    offered_at: { format: :day_month_year, origin: :offered, tag_action: "offered", link_text: "tabs.offered.add_job_offer_date" },
    declined_at: { format: :day_month_year, origin: :offered, tag_action: "declined", link_text: "tabs.offered.add_decline_date" },
    interview_feedback_received_at: { format: :day_month_year, origin: :interviewing, tag_action: "unsuccessful_interview", link_text: "tabs.offered.add_feedback_date" },
    interviewing_at: { format: :day_month_year_time, origin: :interviewing, tag_action: "interview_datetime", link_text: "tabs.interviewing.add_interview_datetime" },
  }.freeze

  private

  def cell(job_application, field)
    case field
    when :name then name_cell(job_application)
    when :email_address then job_application.email_address
    when :status then status_cell(job_application)
    else date_cell(job_application, field, **DATE_FIELDS.fetch(field))
    end
  end

  def name_cell(job_application)
    if job_application.withdrawn?
      tag.span job_application.name
    elsif job_application.vacancy.anonymise_applications? && !job_application.hide_personal_details?
      tag.span do
        govuk_link_to(job_application.name, organisation_job_job_application_path(@vacancy.id, job_application)) +
          tag.p(job_application.anonymised_name, class: "govuk-hint")
      end
    else
      govuk_link_to(job_application.name, organisation_job_job_application_path(@vacancy.id, job_application))
    end
  end

  def status_cell(job_application)
    status_tag = publisher_job_application_status_tag(job_application.status)
    link = checks_link(job_application)
    return status_tag unless link

    tag.div { safe_join([status_tag, tag.br, link]) }
  end

  def checks_link(job_application)
    if job_application.offered?
      govuk_link_to(t("tabs.offered.pre_employment_checks"), pre_employment_checks_organisation_job_job_application_path(@vacancy.id, job_application.id))
    elsif job_application.checks_stage_reached?
      govuk_link_to(t("tabs.interviewing.pre_interview_checks"), pre_interview_checks_organisation_job_job_application_path(@vacancy.id, job_application.id))
    end
  end

  def date_cell(job_application, field, format:, origin:, tag_action:, link_text:)
    date = job_application.public_send(field)
    return date.to_fs(format) if date

    govuk_link_to(t(link_text), tag_organisation_job_job_applications_path(@vacancy.id, params: { publishers_job_application_tag_form: { origin:, job_applications: [job_application.id] }, tag_action: }))
  end
end
