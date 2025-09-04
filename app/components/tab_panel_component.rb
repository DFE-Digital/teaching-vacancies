class TabPanelComponent < ApplicationComponent
  include JobApplicationsHelper

  def initialize(tab_name:,
                 vacancy:,
                 candidates:,
                 displayed_fields: %i[name email_address status],
                 button_group: %i[download update_status],
                 form: nil)
    super(classes: [], html_attributes: {})
    @tab_name = tab_name
    @vacancy = vacancy
    @form = form
    @candidates = candidates
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
      { html_attributes: { data: { module: "moj-multi-select", multi_select_checkbox: "#multi_select_#{@tab_name}", multi_select_idprefix: "id_all_#{@tab_name}" } } }
    else
      {}
    end
  end

  def candidate_checkbox(application, index, form_tag)
    if application.terminal_status?
      tag.span
    else
      tag.div(class: "govuk-checkboxes--small") do
        form_tag.govuk_check_box(:job_applications, application.id,
                                 link_errors: index.zero?,
                                 label: { hidden: true, text: "Select #{application.name}" })
      end
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
    else
      govuk_link_to(application.name, organisation_job_job_application_path(@vacancy.id, application))
    end
  end

  def candidate_status(application)
    if application.post_interview_status?
      tag.div do
        publisher_job_application_status_tag(application.status) \
        + tag.br \
        + govuk_link_to(t("tabs.interviewing.pre_interview_checks"), pre_interview_checks_organisation_job_job_application_path(application.vacancy.id, application.id))
      end
    else
      publisher_job_application_status_tag(application.status)
    end
  end

  def candidate_offered_at(application)
    application.offered_at&.to_fs(:day_month_year)
  end

  def candidate_declined_at(application)
    application.declined_at&.to_fs(:day_month_year)
  end

  def candidate_interview_feedback_received_at(application)
    application.interview_feedback_received_at&.to_fs(:day_month_year)
  end
end
