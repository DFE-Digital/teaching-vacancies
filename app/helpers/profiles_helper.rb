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
end
