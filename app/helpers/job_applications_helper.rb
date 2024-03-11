module JobApplicationsHelper
  PUBLISHER_STATUS_MAPPINGS = {
    submitted: "unread",
    reviewed: "reviewed",
    shortlisted: "shortlisted",
    unsuccessful: "rejected",
    withdrawn: "withdrawn",
  }.freeze

  JOBSEEKER_STATUS_MAPPINGS = {
    deadline_passed: "deadline passed",
    draft: "draft",
    submitted: "submitted",
    reviewed: "submitted",
    shortlisted: "shortlisted",
    unsuccessful: "unsuccessful",
    withdrawn: "withdrawn",
  }.freeze

  JOB_APPLICATION_STATUS_TAG_COLOURS = {
    deadline_passed: "grey",
    draft: "pink",
    submitted: "blue",
    reviewed: "purple",
    shortlisted: "green",
    unsuccessful: "red",
    withdrawn: "yellow",
  }.freeze

  def job_application_qualified_teacher_status_info(job_application)
    case job_application.qualified_teacher_status
    when "yes"
      safe_join([tag.span("Yes, awarded in ", class: "govuk-body", id: "qualified_teacher_status"),
                 tag.span(job_application.qualified_teacher_status_year, class: "govuk-body", id: "qualified_teacher_status_year")])
    when "no"
      safe_join([tag.div("No", class: "govuk-body", id: "qualified_teacher_status"),
                 tag.p(job_application.qualified_teacher_status_details, class: "govuk-body", id: "qualified_teacher_status_details")])
    when "on_track"
      tag.div("I'm on track to receive my QTS", class: "govuk-body", id: "qualified_teacher_status")
    end
  end

  def job_application_support_needed_info(job_application)
    case job_application.support_needed
    when "yes"
      safe_join([tag.div("Yes", class: "govuk-body", id: "support_needed"),
                 tag.p(job_application.support_needed_details, class: "govuk-body", id: "support_needed_details")])
    when "no"
      tag.div("No", id: "support_needed")
    end
  end

  def job_application_close_relationships_info(job_application)
    case job_application.close_relationships
    when "yes"
      safe_join([tag.div("Yes", class: "govuk-body", id: "close_relationships"),
                 tag.p(job_application.close_relationships_details, class: "govuk-body", id: "close_relationships_details")])
    when "no"
      tag.div("No", class: "govuk-body", id: "close_relationships")
    end
  end

  def job_application_safeguarding_issues_info(job_application)
    case job_application.safeguarding_issue
    when "yes"
      safe_join([tag.div("Yes", class: "govuk-body", id: "safeguarding_issue"),
                 tag.p(job_application.safeguarding_issue_details, class: "govuk-body", id: "safeguarding_issue_details")])
    when "no"
      tag.div("No", class: "govuk-body", id: "safeguarding_issue")
    end
  end

  def job_application_status_tag(status)
    govuk_tag text: JOBSEEKER_STATUS_MAPPINGS[status.to_sym],
              colour: JOB_APPLICATION_STATUS_TAG_COLOURS[JOBSEEKER_STATUS_MAPPINGS[status.to_sym].parameterize.underscore.to_sym],
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

  def job_application_build_submit_button_text
    if redirect_to_review?
      t("buttons.save")
    else
      t("buttons.save_and_continue")
    end
  end

  def job_application_view_applicant(vacancy, job_application)
    if job_application.withdrawn?
      tag.span job_application.name
    else
      govuk_link_to job_application.name, organisation_job_job_application_path(vacancy.id, job_application)
    end
  end

  def job_application_page_title_prefix(form, title)
    if form.errors.any?
      "Error: #{title}"
    else
      title
    end
  end

  def job_application_step_in_progress?(job_application, step)
    job_application.in_progress_steps.include?(step.to_s)
  end

  def visa_sponsorship_available_answer
    if job_application.right_to_work_in_uk == "yes"
      t("jobseekers.profiles.personal_details.work.options.true")
    elsif job_application.right_to_work_in_uk == "no"
      t("jobseekers.profiles.personal_details.work.options.false")
    end
  end

  def radio_button_legend_hint
    if vacancy.visa_sponsorship_available?
      {
        text: "jobseekers.profiles.personal_details.work.hint.text",
        link: "jobseekers.profiles.personal_details.work.hint.link",
      }
    else
      {
        text: "jobseekers.profiles.personal_details.work.hint.no_visa.text",
        link: "jobseekers.profiles.personal_details.work.hint.no_visa.link",
      }
    end
  end
end
