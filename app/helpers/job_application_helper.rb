module JobApplicationHelper
  PUBLISHER_STATUS_MAPPINGS = { shortlisted: "shortlisted", submitted: "review", unsuccessful: "rejected", withdrawn: "withdrawn" }.freeze

  JOB_APPLICATION_STATUS_TAG_COLOURS = {
    draft: "pink", submitted: "blue", shortlisted: "green", unsuccessful: "red", withdrawn: "grey"
  }.freeze

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
end
