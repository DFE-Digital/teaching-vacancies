module ProfilesHelper
  def job_application_qualified_teaching_status_info(profile)
    case profile.qualified_teaching_status
    when "yes"
      safe_join([tag.span("Yes, awarded in ", class: "govuk-body", id: "qualified_teaching_status"),
                 tag.span(profile.qualified_teaching_status_year, class: "govuk-body", id: "qualified_teaching_status_year")])
    when "no"
      safe_join([tag.div("No", class: "govuk-body", id: "qualified_teaching_status"),
                 tag.p(profile.qualified_teaching_status, class: "govuk-body", id: "qualified_teaching_status")])
    when "on_track"
      tag.div("I'm on track to receive my QTS", class: "govuk-body", id: "qualified_teaching_status")
    end
  end

  def jobseeker_status(profile)
    [qualified_teacher_status_string(profile), right_to_work_status_string(profile)].compact.join(' ')
  end

  private

  def qualified_teacher_status_string(profile)
    case profile.qualified_teacher_status
    when "on_track"
      "On track to receive QTS."
    when "yes"
      "QTS awarded in #{profile.qualified_teacher_status_year}."
    when "no"
      "Does not have QTS."
    else
      ""
    end
  end

  def right_to_work_status_string(profile)
    return nil if profile&.personal_details&.right_to_work_in_uk.nil?

    profile.personal_details.right_to_work_in_uk ? "Has the right to work in the UK." : "Does not have the right to work in the UK."
  end
end
