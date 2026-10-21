class TabPanelComponent < ApplicationComponent
  include JobApplicationsHelper

  # date fields, with the tag action that lets a publisher fill one in when it is missing
  DATE_ACTIONS = {
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
                 form: nil,
                 sort_by: nil)
    super(html_attributes: { class: "tab-#{tab_name}" })
    @tab_name = tab_name
    @vacancy = vacancy
    @form = form
    @candidates = sort_by ? sort_candidates(candidates, sort_by) : candidates
    @displayed_fields = displayed_fields
    @button_group = button_group
  end

  def form_with_args
    if @form.present?
      { model: @form, url: tag_organisation_job_job_applications_path(@vacancy.id), method: :get }
    else
      { url: "" }
    end
  end

  def govuk_table_args
    if @form.present?
      { html_attributes: { data: { controller: "multi-select", id_prefix: "id_all_#{@tab_name}-" } } }
    else
      {}
    end
  end

  def candidate_checkbox(application, index, form_tag)
    if application.unsuccessful? || !application.terminal_status?
      tag.div(class: "govuk-checkboxes--small") do
        form_tag.govuk_check_box(:job_applications, application.id,
                                 link_errors: index.zero?,
                                 label: { hidden: true, text: "Select #{application.name}" })
      end
    else
      tag.span
    end
  end

  def displayed_value(application, field)
    case field
    when :name then candidate_name(application)
    when :status then candidate_status(application)
    when :email_address then application.email_address
    when *DATE_ACTIONS.keys then candidate_date(application, field, **DATE_ACTIONS.fetch(field))
    else raise ArgumentError, "Unknown field: #{field}"
    end
  end

  def candidate_name(application)
    if application.withdrawn?
      tag.span application.name
    elsif application.vacancy.anonymise_applications? && !application.hide_personal_details?
      tag.span do
        govuk_link_to(application.name, organisation_job_job_application_path(@vacancy.id, application)) +
          tag.p(application.anonymised_name, class: "govuk-hint")
      end
    else
      govuk_link_to(application.name, organisation_job_job_application_path(@vacancy.id, application))
    end
  end

  # rubocop:disable Metrics/AbcSize
  def candidate_status(application)
    # need to show pre-interview checks iff candidate in interview state or later
    if application.offered?
      tag.div do
        publisher_job_application_status_tag(application.status) \
          + tag.br \
          + govuk_link_to(t("tabs.offered.pre_employment_checks"), pre_employment_checks_organisation_job_job_application_path(application.vacancy.id, application.id))
      end
    elsif application.has_pre_interview_checks?
      tag.div do
        publisher_job_application_status_tag(application.status) \
        + tag.br \
        + govuk_link_to(t("tabs.interviewing.pre_interview_checks"), pre_interview_checks_organisation_job_job_application_path(application.vacancy.id, application.id))
      end
    else
      publisher_job_application_status_tag(application.status)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def candidate_date(application, field, origin:, tag_action:, link_text:, format: :day_month_year)
    if (value = application.public_send(field))
      value.to_fs(format)
    else
      govuk_link_to(t(link_text), tag_organisation_job_job_applications_path(application.vacancy.id, params: { publishers_job_application_tag_form: { origin:, job_applications: [application.id] }, tag_action: }))
    end
  end

  # candidates without a value come first, as they need action from the publisher
  def sort_candidates(candidates, field)
    candidates.sort_by { |candidate| [candidate.public_send(field).nil? ? 0 : 1, candidate.public_send(field)] }
  end
end
