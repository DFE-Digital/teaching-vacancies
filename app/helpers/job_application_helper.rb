module JobApplicationHelper
  PUBLISHER_STATUS_MAPPINGS = {
    submitted: "unread",
    reviewed: "reviewed",
    shortlisted: "shortlisted",
    unsuccessful: "rejected",
    withdrawn: "withdrawn",
  }.freeze

  JOBSEEKER_STATUS_MAPPINGS = {
    draft: "draft",
    submitted: "submitted",
    reviewed: "submitted",
    shortlisted: "shortlisted",
    unsuccessful: "unsuccessful",
    withdrawn: "withdrawn",
  }.freeze

  JOB_APPLICATION_STATUS_TAG_COLOURS = {
    draft: "pink",
    submitted: "blue",
    reviewed: "purple",
    shortlisted: "green",
    unsuccessful: "red",
    withdrawn: "orange",
  }.freeze

  def job_application_qualified_teacher_status_info(job_application)
    case job_application.qualified_teacher_status
    when "yes"
      tag.div("Yes, awarded in #{job_application.qualified_teacher_status_year}", class: "govuk-body")
    when "no"
      safe_join([tag.div("No", class: "govuk-body"),
                 tag.p(job_application.qualified_teacher_status_details, class: "govuk-body")])
    when "on_track"
      tag.div("I'm on track to receive my QTS", class: "govuk-body")
    end
  end

  def job_application_support_needed_info(job_application)
    case job_application.support_needed
    when "yes"
      safe_join([tag.div("Yes", class: "govuk-body"),
                 tag.p(job_application.support_needed_details, class: "govuk-body")])
    when "no"
      tag.div("No", class: "govuk-body")
    end
  end

  def job_application_close_relationships_info(job_application)
    case job_application.close_relationships
    when "yes"
      safe_join([tag.div("Yes", class: "govuk-body"),
                 tag.p(job_application.close_relationships_details, class: "govuk-body")])
    when "no"
      tag.div("No", class: "govuk-body")
    end
  end

  def job_application_status_tag(status)
    govuk_tag text: JOBSEEKER_STATUS_MAPPINGS[status.to_sym],
              colour: JOB_APPLICATION_STATUS_TAG_COLOURS[JOBSEEKER_STATUS_MAPPINGS[status.to_sym].to_sym],
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

  def job_application_build_submit_button_text
    if redirect_to_review?
      t("buttons.save")
    else
      t("buttons.save_and_continue")
    end
  end
end
