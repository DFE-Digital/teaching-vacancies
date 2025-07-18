module VacancyFormsHelper
  def vacancy_job_title_form_hint_text(vacancy)
    first_role = vacancy.job_roles.first
    case first_role
    when "teacher"
      teacher_job_title_hint_text(vacancy)
    when "headteacher", "deputy_headteacher", "assistant_headteacher"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.senior_leader")
    when "head_of_year_or_phase", "head_of_department_or_curriculum"
      middle_leader_job_title_hint_text(vacancy)
    when "education_support", "higher_level_teaching_assistant", "sendco", "teaching_assistant"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.#{first_role}")
    end
  end

  def vacancy_review_form_heading_inset_text(vacancy, status)
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

  def vacancy_convert_to_draft_action_link(vacancy)
    govuk_link_to(t("publishers.vacancies.show.heading_component.action.convert_to_draft"), organisation_job_convert_to_draft_path(vacancy.id), class: "govuk-!-margin-bottom-0")
  end

  def vacancy_close_early_action_link(vacancy)
    govuk_link_to(t("publishers.vacancies.show.heading_component.action.close_early"), organisation_job_end_listing_path(vacancy.id), class: "govuk-!-margin-bottom-0")
  end

  def vacancy_extend_closing_date_action_link(vacancy)
    govuk_link_to(t("publishers.vacancies.show.heading_component.action.extend_closing_date"), organisation_job_extend_deadline_path(vacancy.id), class: "govuk-!-margin-bottom-0")
  end

  def vacancy_publish_action_link(vacancy)
    govuk_button_link_to(t("publishers.vacancies.show.heading_component.action.publish"), organisation_job_publish_path(vacancy.id), class: "govuk-!-margin-bottom-0")
  end

  def vacancy_preview_action_link(vacancy)
    open_in_new_tab_link_to(t("publishers.vacancies.show.heading_component.action.preview"), organisation_job_preview_path(vacancy.id), class: "govuk-!-margin-bottom-0")
  end

  def vacancy_schedule_complete_draft_action_link(vacancy)
    govuk_button_link_to(t("publishers.vacancies.show.heading_component.action.scheduled_complete_draft"), organisation_job_publish_path(vacancy.id), class: "govuk-!-margin-bottom-0")
  end

  def vacancy_view_action_link(vacancy)
    open_in_new_tab_link_to(t("publishers.vacancies.show.heading_component.action.view"), job_path(vacancy.id), class: "govuk-!-margin-bottom-0")
  end

  def vacancy_relist_action_link(vacancy)
    govuk_link_to(t("publishers.vacancies.show.heading_component.action.relist"), organisation_job_relist_path(vacancy.id), class: "govuk-!-margin-bottom-0", method: :post)
  end

  def vacancy_give_feedback_action_link(vacancy)
    govuk_link_to(t("publishers.vacancies.show.heading_component.action.give_feedback"), new_organisation_job_expired_feedback_path(job_id: vacancy.id))
  end

  def vacancy_complete_action_link(vacancy, next_invalid_step)
    govuk_button_link_to(t("publishers.vacancies.show.heading_component.action.complete"), organisation_job_build_path(vacancy.id, next_invalid_step, back_to_show: "true"), class: "govuk-!-margin-bottom-0")
  end

  def vacancy_copy_action_link(vacancy)
    govuk_link_to(t("publishers.vacancies.show.heading_component.action.copy"), organisation_job_copy_path(vacancy.id), class: "govuk-!-margin-bottom-0", method: :post)
  end

  def vacancy_delete_action_link(vacancy)
    govuk_link_to(t("publishers.vacancies.show.heading_component.action.delete"), organisation_job_confirm_destroy_path(vacancy.id), class: "govuk-!-margin-bottom-0")
  end

  private

  def teacher_job_title_hint_text(vacancy)
    case vacancy.phases.first
    when "nursery"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.teacher.nursery")
    when "primary"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.teacher.primary")
    when "secondary", "sixth_form_or_college"
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
    when "secondary", "sixth_form_or_college"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.middle_leader.middle_secondary_or_sixth_form_or_college")
    when "through"
      t("helpers.hint.publishers_job_listing_job_title_form.job_title.middle_leader.through")
    end
  end
end
