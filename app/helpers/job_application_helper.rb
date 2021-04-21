module JobApplicationHelper
  PUBLISHER_STATUS_MAPPINGS = {
    shortlisted: "shortlisted", submitted: "review", unsuccessful: "rejected", withdrawn: "withdrawn"
  }.freeze

  JOB_APPLICATION_STATUS_TAG_COLOURS = {
    draft: "pink", submitted: "blue", shortlisted: "green", unsuccessful: "red", withdrawn: "orange"
  }.freeze

  def job_application_qualified_teacher_status_info(job_application)
    return unless job_application.qualified_teacher_status.present?

    safe_join([tag.div(I18n.t("helpers.label.jobseekers_job_application_professional_status_form.qualified_teacher_status_options.#{job_application.qualified_teacher_status}"), class: "govuk-body"),
               tag.p(job_application.qualified_teacher_status == "yes" ? job_application.qualified_teacher_status_year : job_application.qualified_teacher_status_details, class: "govuk-body")])
  end

  def job_application_status_tag(status)
    govuk_tag text: status,
              colour: JOB_APPLICATION_STATUS_TAG_COLOURS[status.to_sym],
              classes: "govuk-!-margin-bottom-2"
  end

  def publisher_job_application_status_tag(status)
    govuk_tag text: PUBLISHER_STATUS_MAPPINGS[status.to_sym],
              colour: JOB_APPLICATION_STATUS_TAG_COLOURS[status.to_sym],
              classes: "govuk-!-margin-bottom-2"
  end

  def status_tag_colour(status)
    JOB_APPLICATION_STATUS_TAG_COLOURS[status]
  end

  def job_application_review_edit_section_text(job_application, step)
    return t("buttons.change") if step.to_s.in?(job_application.completed_steps)

    t("buttons.complete_section")
  end

  def job_application_review_section_tag(job_application, step)
    tag_attributes = if step.to_s.in?(job_application.completed_steps)
                       { text: "complete" }
                     elsif step.to_s.in?(job_application.in_progress_steps)
                       { text: "in progress", colour: "yellow" }
                     else
                       { text: "not started", colour: "red" }
                     end

    govuk_tag(**tag_attributes)
  end
end
