module JobApplicationsHelper
  PUBLISHER_STATUS_MAPPINGS = {
    submitted: "unread",
    reviewed: "reviewed",
    shortlisted: "shortlisted",
    unsuccessful: "not progressing",
    rejected: "not progressing",
    withdrawn: "withdrawn",
    interviewing: "interviewing",
    unsuccessful_interview: "not progressing",
    offered: "job offered",
    declined: "job declined",
  }.freeze

  JOBSEEKER_STATUS_MAPPINGS = {
    deadline_passed: "job closed",
    draft: "draft",
    submitted: "submitted",
    reviewed: "submitted",
    shortlisted: "shortlisted",
    unsuccessful: "unsuccessful",
    rejected: "unsuccessful",
    withdrawn: "withdrawn",
    interviewing: "interviewing",
    unsuccessful_interview: "unsuccessful",
    action_required: "needs action",
    offered: "offered",
    declined: "declined",
  }.freeze

  JOB_APPLICATION_STATUS_TAG_COLOURS = {
    deadline_passed: "grey",
    draft: "pink",
    submitted: "light-blue",
    reviewed: "purple",
    shortlisted: "orange",
    unsuccessful: "red",
    rejected: "red",
    withdrawn: "grey",
    action_required: "orange",
    interviewing: "turquoise",
    unsuccessful_interview: "red",
    offered: "purple",
    declined: "grey",
  }.freeze

  TABS_DEFINITION = {
    submitted: %w[submitted reviewed],
    unsuccessful: %w[unsuccessful withdrawn rejected],
    shortlisted: %w[shortlisted],
    interviewing: %w[interviewing unsuccessful_interview],
    offered: %w[offered declined],
  }.stringify_keys.freeze

  REVERSE_TABS_LOOKUP = TABS_DEFINITION.invert
                                       .flat_map { |keys, v| keys.map { |k| [k, v] } }
                                       .to_h.freeze

  def job_applications_to_tabs(job_applications_hash)
    TABS_DEFINITION.transform_values do |status_list|
      # There might not be any applications with a particular status, so fill with empty list
      status_list.index_with { |status| job_applications_hash.fetch(status, []) }
    end
  end

  def tab_name(job_application_status)
    REVERSE_TABS_LOOKUP.fetch(job_application_status)
  end

  def tag_status_options(tab_origin)
    job_application_status = TABS_DEFINITION[tab_origin].first
    JobApplication.next_statuses(job_application_status) - %w[withdrawn]
  end

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

  def organisation_label_type(organisation)
    organisation.trust? ? :trust : :other
  end

  def end_date(date, index)
    return "present" if index.zero?

    date.to_fs(:month_year)
  end

  def job_application_trn(job_application)
    job_application.teacher_reference_number.presence || "None"
  end

  def job_application_support_needed_info(job_application)
    case job_application.is_support_needed
    when true
      safe_join([tag.div("Yes", class: "govuk-body", id: "support_needed"),
                 tag.p(job_application.support_needed_details, class: "govuk-body", id: "support_needed_details")])
    when false
      tag.div("No", id: "support_needed")
    end
  end

  def job_application_life_abroad_info(job_application)
    if job_application.has_lived_abroad?
      safe_join([tag.div("Yes", class: "govuk-body", id: "life_abroad"),
                 tag.p(job_application.life_abroad_details, class: "govuk-body", id: "life_abroad_details")])
    else
      tag.div("No", class: "govuk-body", id: "life_abroad")
    end
  end

  def job_application_close_relationships_info(job_application)
    case job_application.has_close_relationships
    when true
      safe_join([tag.div("Yes", class: "govuk-body", id: "close_relationships"),
                 tag.p(job_application.close_relationships_details, class: "govuk-body", id: "close_relationships_details")])
    when false
      tag.div("No", class: "govuk-body", id: "close_relationships")
    end
  end

  def job_application_safeguarding_issues_info(job_application)
    if job_application.has_safeguarding_issue
      safe_join([tag.div("Yes", class: "govuk-body", id: "safeguarding_issue"),
                 tag.p(job_application.safeguarding_issue_details, class: "govuk-body", id: "safeguarding_issue_details")])
    else
      tag.div("No", class: "govuk-body", id: "safeguarding_issue")
    end
  end

  def job_application_status_tag(status)
    govuk_tag text: JOBSEEKER_STATUS_MAPPINGS[status.to_sym],
              colour: JOB_APPLICATION_STATUS_TAG_COLOURS[JOBSEEKER_STATUS_MAPPINGS.fetch(status.to_sym).parameterize.underscore.to_sym],
              classes: "govuk-!-margin-bottom-2"
  end

  def publisher_job_application_status_tag(status, classes: [])
    default_classes = ["application-status", "govuk-!-margin-bottom-2"]
    govuk_tag text: PUBLISHER_STATUS_MAPPINGS.fetch(status.to_sym),
              colour: JOB_APPLICATION_STATUS_TAG_COLOURS.fetch(status.to_sym),
              classes: (default_classes + classes).join(" ")
  end

  def status_tag_colour(status)
    JOB_APPLICATION_STATUS_TAG_COLOURS[status]
  end

  def job_application_link(job_application)
    job_application.draft? ? jobseekers_job_application_apply_path(job_application) : jobseekers_job_application_path(job_application)
  end

  def job_application_build_submit_button_text
    if redirect_to_review?
      t("buttons.save")
    else
      t("buttons.save_and_continue")
    end
  end

  def job_application_page_title_prefix(form, title)
    if form.errors.any?
      "Error: #{title}"
    else
      title
    end
  end

  def visa_sponsorship_needed_answer(job_application)
    unless job_application.has_right_to_work_in_uk.nil?
      I18n.t("jobseekers.profiles.personal_details.work.options.#{job_application.has_right_to_work_in_uk}")
    end
  end

  def radio_button_legend_hint(vacancy)
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

  def readable_working_patterns(job_application)
    job_application.working_patterns.map { |working_pattern|
      JobApplication.human_attribute_name("working_patterns.#{working_pattern}").downcase
    }.join(", ").capitalize
  end

  def new_application_path(vacancy)
    if vacancy.uploaded_form?
      jobseekers_job_job_application_path(vacancy.id)
    else
      new_jobseekers_job_job_application_path(vacancy.id)
    end
  end
end
