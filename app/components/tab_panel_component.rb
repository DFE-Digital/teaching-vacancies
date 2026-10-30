class TabPanelComponent < ApplicationComponent
  include JobApplicationsHelper

  # Date columns, and the tag action that lets a publisher add the date when it is missing
  DATE_FIELDS = {
    offered_at: { origin: :offered, tag_action: "offered", link_text: "tabs.offered.add_job_offer_date" },
    declined_at: { origin: :offered, tag_action: "declined", link_text: "tabs.offered.add_decline_date" },
    interview_feedback_received_at: { origin: :interviewing, tag_action: "unsuccessful_interview", link_text: "tabs.offered.add_feedback_date" },
    interviewing_at: { origin: :interviewing, tag_action: "interview_datetime", link_text: "tabs.interviewing.add_interview_datetime", format: :default },
  }.freeze

  def initialize(tab_name:,
                 vacancy:,
                 candidates:,
                 displayed_fields: %i[name email_address status],
                 button_group: %i[download update_status],
                 form: nil)
    super(html_attributes: { class: "tab-#{tab_name}" })
    @tab_name = tab_name
    @vacancy = vacancy
    @form = form
    @candidates = candidates
    @displayed_fields = displayed_fields
    @button_group = button_group
  end

  private

  # With a form, publishers can select candidates and act on them with the button group
  def selectable?
    @form.present?
  end

  def form_with_args
    if selectable?
      { model: @form, url: tag_organisation_job_job_applications_path(@vacancy.id), method: :get }
    else
      { url: "" }
    end
  end

  def govuk_table_args
    if selectable?
      { html_attributes: { data: { controller: "multi-select", id_prefix: "id_all_#{@tab_name}-" } } }
    else
      {}
    end
  end

  # Applications in a terminal status can't move on, so there is nothing to select them for
  def checkbox_cell(job_application, index, form)
    return tag.span if job_application.terminal_status?

    tag.div(class: "govuk-checkboxes--small") do
      form.govuk_check_box(:job_applications, job_application.id,
                           link_errors: index.zero?,
                           label: { hidden: true, text: "Select #{job_application.name}" })
    end
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
    return link unless @vacancy.anonymise_applications? && !job_application.hide_personal_details?

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
