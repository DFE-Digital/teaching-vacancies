# A table of job applications. SelectableCandidatesTableComponent adds a column of checkboxes
# so publishers can select candidates and act on them.
class CandidatesTableComponent < ApplicationComponent
  include JobApplicationsHelper

  # Date columns, and the tag action that lets a publisher add the date when it is missing
  DATE_FIELDS = {
    offered_at: { origin: :offered, tag_action: "offered", link_text: "tabs.offered.add_job_offer_date" },
    declined_at: { origin: :offered, tag_action: "declined", link_text: "tabs.offered.add_decline_date" },
    interview_feedback_received_at: { origin: :interviewing, tag_action: "unsuccessful_interview", link_text: "tabs.offered.add_feedback_date" },
    interviewing_at: { origin: :interviewing, tag_action: "interview_datetime", link_text: "tabs.interviewing.add_interview_datetime", format: :default },
  }.freeze

  def initialize(vacancy:, candidates:, displayed_fields: %i[name email_address status])
    super()
    @vacancy = vacancy
    # Decorated here so personal details stay hidden whatever the caller passes
    @candidates = JobApplicationDecorator.decorate_collection(candidates)
    @displayed_fields = displayed_fields
  end

  private

  def table_args
    {}
  end

  def header_cells
    @displayed_fields.map { |field| { text: t("tabs.headers.#{field}") } }
  end

  def row_cells(job_application, _index)
    @displayed_fields.map { |field| { text: cell(job_application, field), html_attributes: { class: field.to_s } } }
  end

  def cell(job_application, field)
    case field
    when :name then name_cell(job_application)
    when :email_address then job_application.email_address
    when :status then status_cell(job_application)
    else date_cell(job_application, field, **DATE_FIELDS.fetch(field))
    end
  end

  def name_cell(job_application)
    return tag.span(job_application.name) if job_application.withdrawn?

    link = govuk_link_to(job_application.name, organisation_job_job_application_path(@vacancy.id, job_application))
    return link unless job_application.show_anonymised_reference?

    tag.span { link + tag.p(job_application.anonymised_name, class: "govuk-hint") }
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
    elsif job_application.has_pre_interview_checks?
      govuk_link_to(t("tabs.interviewing.pre_interview_checks"), pre_interview_checks_organisation_job_job_application_path(@vacancy.id, job_application.id))
    end
  end

  def date_cell(job_application, field, origin:, tag_action:, link_text:, format: :day_month_year)
    date = job_application.public_send(field)
    return date.to_fs(format) if date

    govuk_link_to(t(link_text), tag_organisation_job_job_applications_path(@vacancy.id, params: { publishers_job_application_tag_form: { origin:, job_applications: [job_application.id] }, tag_action: }))
  end
end
