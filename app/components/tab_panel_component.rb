class TabPanelComponent < ApplicationComponent
  include JobApplicationsHelper

  def initialize(tab_name:,
                 vacancy:,
                 candidates:,
                 displayed_fields: %i[name email_address status],
                 button_group: %i[download update_status],
                 form: nil)
    super(classes: [], html_attributes: { class: "tab-#{tab_name}" })
    @tab_name = tab_name
    @vacancy = vacancy
    @form = form
    @candidates = sort_candidates(candidates, tab_name)
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
      { html_attributes: { data: { module: "moj-multi-select", id_prefix: "id_all_#{@tab_name}-" } } }
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
    helper_method = :"candidate_#{field}"
    if respond_to?(helper_method)
      public_send(helper_method, application)
    else
      application.public_send(field)
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

  def candidate_offered_at(application)
    if application.offered_at
      application.offered_at.to_fs(:day_month_year)
    else
      govuk_link_to(t("tabs.offered.add_job_offer_date"), tag_organisation_job_job_applications_path(application.vacancy.id, params: { publishers_job_application_tag_form: { origin: :offered, job_applications: [application.id] }, tag_action: "offered" }))
    end
  end

  def candidate_declined_at(application)
    if application.declined_at
      application.declined_at.to_fs(:day_month_year)
    else
      govuk_link_to(t("tabs.offered.add_decline_date"), tag_organisation_job_job_applications_path(application.vacancy.id, params: { publishers_job_application_tag_form: { origin: :offered, job_applications: [application.id] }, tag_action: "declined" }))
    end
  end

  def candidate_interview_feedback_received_at(application)
    if application.interview_feedback_received_at
      application.interview_feedback_received_at.to_fs(:day_month_year)
    else
      govuk_link_to(t("tabs.offered.add_feedback_date"), tag_organisation_job_job_applications_path(application.vacancy.id, params: { publishers_job_application_tag_form: { origin: :interviewing, job_applications: [application.id] }, tag_action: "unsuccessful_interview" }))
    end
  end

  def candidate_interviewing_at(application)
    if application.interviewing_at
      application.interviewing_at.to_fs
    else
      tag.span do
        govuk_link_to(t("tabs.interviewing.add_interview_datetime"), tag_organisation_job_job_applications_path(application.vacancy.id, params: { publishers_job_application_tag_form: { origin: :interviewing, job_applications: [application.id] }, tag_action: "interview_datetime" }))
      end
    end
  end

  def sort_candidates(candidates, tab_name)
    case tab_name
    when "interviewing"
      candidates.sort_by { |candidate| [candidate.interviewing_at.nil? ? 0 : 1, candidate.interviewing_at] }
    when "offered"
      candidates.sort_by { |candidate| [candidate.offered_at.nil? ? 0 : 1, candidate.offered_at] }
    when "declined"
      candidates.sort_by { |candidate| [candidate.declined_at.nil? ? 0 : 1, candidate.declined_at] }
    else
      candidates
    end
  end
end
