module VacancyFormsHelper
  def vacancy_about_school_form_hint_text(vacancy)
    return t("helpers.hint.publishers_job_listing_about_the_role_form.about_schools", organisation_type: organisation_type_basic(vacancy.organisation)) if vacancy.organisations.many?

    t("helpers.hint.publishers_job_listing_about_the_role_form.about_organisation", organisation_type: organisation_type_basic(vacancy.organisation).capitalize)
  end

  def vacancy_about_school_form_label(vacancy)
    vacancy.organisations.many? ? "the schools" : vacancy.organisation_name
  end

  def vacancy_job_title_form_hint_text(vacancy)
    t("helpers.hint.publishers_job_listing_job_title_form.job_title.#{vacancy.job_role}") unless vacancy.job_role.in?(%w[teacher senior_leader middle_leader])

    case vacancy.job_role
    when "teacher"
      teacher_job_title_hint_text(vacancy)
    when "senior_leader"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.senior_leader")
    when "middle_leader"
      middle_leader_job_title_hint_text(vacancy)
    end
  end

  def vacancy_review_form_heading_inset_text(vacancy, status) # rubocop:disable Metrics/MethodLength
    case status
    when "published"
      t("publishers.vacancies.show.heading_component.inset_text.published", publish_date: format_date(vacancy.publish_on),
                                                                            expiry_time: format_time_to_datetime_at(vacancy.expires_at))
    when "complete_draft"
      if vacancy.publish_on.future?
        t("publishers.vacancies.show.heading_component.inset_text.scheduled_complete_draft")
      else
        t("publishers.vacancies.show.heading_component.inset_text.complete_draft")
      end
    when "incomplete_draft"
      t("publishers.vacancies.show.heading_component.inset_text.incomplete_draft")
    when "closed"
      t("publishers.vacancies.show.heading_component.inset_text.closed", publish_date: format_date(vacancy.publish_on),
                                                                         expiry_time: format_time_to_datetime_at(vacancy.expires_at))
    when "scheduled"
      t("publishers.vacancies.show.heading_component.inset_text.scheduled", publish_date: format_date(vacancy.publish_on),
                                                                            expiry_time: format_time_to_datetime_at(vacancy.expires_at))
    end
  end

  def vacancy_review_form_heading_action_link(vacancy, action) # rubocop:disable Metrics/AbcSize,  Metrics/MethodLength
    case action
    when "view"
      open_in_new_tab_link_to(t("publishers.vacancies.show.heading_component.action.view"), job_path(vacancy.id), class: "govuk-!-margin-bottom-0")
    when "copy"
      govuk_link_to(t("publishers.vacancies.show.heading_component.action.copy"), organisation_job_copy_path(vacancy.id), class: "govuk-!-margin-bottom-0", method: :post)
    when "close_early"
      govuk_link_to(t("publishers.vacancies.show.heading_component.action.close_early"), organisation_job_end_listing_path(vacancy.id), class: "govuk-!-margin-bottom-0")
    when "extend_closing_date"
      govuk_link_to(t("publishers.vacancies.show.heading_component.action.extend_closing_date"), organisation_job_extend_deadline_path(vacancy.id), class: "govuk-!-margin-bottom-0")
    when "publish"
      govuk_button_link_to(t("publishers.vacancies.show.heading_component.action.publish"), organisation_job_publish_path(vacancy.id), class: "govuk-!-margin-bottom-0")
    when "preview"
      open_in_new_tab_link_to(t("publishers.vacancies.show.heading_component.action.preview"), organisation_job_preview_path(vacancy.id), class: "govuk-!-margin-bottom-0")
    when "delete"
      govuk_link_to(t("publishers.vacancies.show.heading_component.action.delete"), organisation_job_confirm_destroy_path(vacancy.id), class: "govuk-!-margin-bottom-0")
    when "complete"
      govuk_button_link_to(t("publishers.vacancies.show.heading_component.action.complete"), organisation_job_build_path(vacancy.id, next_invalid_step, back_to_show: "true"), class: "govuk-!-margin-bottom-0")
    when "convert_to_draft"
      govuk_link_to(t("publishers.vacancies.show.heading_component.action.convert_to_draft"), organisation_job_convert_to_draft_path(vacancy.id), class: "govuk-!-margin-bottom-0")
    when "schedule_complete_draft"
      govuk_button_link_to(t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft"), organisation_job_publish_path(vacancy.id), class: "govuk-!-margin-bottom-0")
    end
  end

  private

  def teacher_job_title_hint_text(vacancy)
    case vacancy.phases.first
    when "nursery"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.teacher.nursery")
    when "primary"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.teacher.primary")
    when "middle" || "secondary" || "sixth_form_or_college"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.teacher.middle_secondary_or_sixth_form_or_college")
    when "through"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.teacher.through")
    end
  end

  def middle_leader_job_title_hint_text(vacancy)
    case vacancy.phases.first
    when "nursery"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.middle_leader.nursery")
    when "primary"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.middle_leader.primary")
    when "middle" || "secondary" || "sixth_form_or_college"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.middle_leader.middle_secondary_or_sixth_form_or_college")
    when "through"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.middle_leader.through")
    end
  end
end
